# frozen_string_literal: true

require 'httpclient/include_client'

class ZyncWorker
  include Sidekiq::Worker
  include ThreeScale::SidekiqRetrySupport::Worker

  extend ::HTTPClient::IncludeClient

  class_attribute :publisher
  self.publisher = ->(*args) { Rails.application.config.event_store.publish_event(*args) }

  sidekiq_options queue: :zync

  # It is used as the delay, in seconds.
  # The default variable is the same as sidekiq's default, as you can see in https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry
  # the default would last up 20 days and some hours, and we need it to last less than 7 days for the event to still exist,
  # so it goes 3 times faster to last maximum 6 days and some hours (1/3 = 7/21)
  sidekiq_retry_in do |count, _exception|
    default = (count ** 4) + 15 + (rand(30) * (count + 1))
    default / 3
  end

  def self.config
    Rails.configuration.zync
  end

  include_http_client do |client|
    client.debug_dev = $stdout if config.debug

    client.connect_timeout = config.connect_timeout || client.connect_timeout
    client.receive_timeout = config.receive_timeout || client.receive_timeout
    client.send_timeout = config.send_timeout || client.send_timeout
  end

  class InvalidResponseError < StandardError
    include Bugsnag::MetaData

    def initialize(response)
      super "Expected successful response. Got #{response.status}"
      self.bugsnag_meta_data = {
        response: response.as_json,
      }
    end
  end

  class UnprocessableEntityError < InvalidResponseError; end

  Bugsnag::Middleware::ClassifyError::INFO_CLASSES << UnprocessableEntityError.to_s

  module Locator
    module_function

    # :reek:FeatureEnvy can be ignored here
    def locate(gid)
      find_model(gid.model_name).find(gid.model_id)
    end

    def find_model(name)
      case name
      when 'Application'
        Cinstance
      else
        name.constantize
      end
    end

    GlobalID::Locator.use(:zync, Locator)
  end

  def perform(event_id, notification, manual_retry_count = nil)
    return false unless valid?(event_id)
    event = EventStore::Repository.find_event!(event_id)

    with_manual_retry_count(event_id, manual_retry_count) do
      update_tenant(event)
      http_put(notification_url, notification, event_id)
    end
  rescue UnprocessableEntityError
    raise if last_attempt? || sync_dependencies(event_id).blank?
  end

  attr_reader :manual_retry_count, :event_id

  def with_manual_retry_count(event_id, manual_retry_count)
    @event_id = event_id
    set_retry_count(manual_retry_count)
    with_retry_log { yield }
  end

  def set_retry_count(manual_retry_count)
    return unless manual_retry_count
    self.retry_attempt += manual_retry_count # Retries can be Sidekiq retries or manual retries
    @manual_retry_count = manual_retry_count
  end

  def valid?(event_id)
    unless endpoint
      Rails.logger.warn "Skipping Zync for event #{event_id}. URL not configured."
      return false
    end

    true
  end

  def sync_dependencies(event_id)
    dependency_events = []

    enqueue_dependency_batch(event_id) do
      dependency_events = create_dependency_events(event_id)
      publish_dependency_events(dependency_events)
    end

    dependency_events
  end

  def enqueue_dependency_batch(event_id, &block)
    batch = Sidekiq::Batch.new
    batch.description = "[ZyncWorker] Syncing dependencies first"
    batch.on(:complete, self.class, { 'event_id' => event_id, 'manual_retry_count' => manual_retry_count })
    batch.jobs &block
  end

  def create_dependency_events(event_id)
    EventStore::Repository.find_event!(event_id).create_dependencies
  end

  def publish_dependency_events(dependency_events)
    dependency_events.each do |dependent_event|
      publisher.call(dependent_event, 'zync')
    end
  end

  def on_complete(_bid, options)
    event = EventStore::Repository.find_event!(options['event_id'])

    # A batch is only created after a UnprocessableEntityError has been raised, so retry the same event
    # The number of retries is usually controlled at the origin of the failure using ThreeScale::SidekiqRetrySupport::Worker#last_attempt?,
    # but in this case we are not really using Sidekiq retries, but rather re-enqueueing the job manually here
    manual_retry_count = options['manual_retry_count'].to_i + 1
    perform_async(event.event_id, event.data.to_json, manual_retry_count)
  end

  delegate :perform_async, to: :class

  def update_tenant(event)
    provider = Provider.find(event.tenant_id)

    tenant = {
      id: provider.id,
      endpoint: provider_endpoint(provider),
      access_token: provider_access_token(provider),
    }

    http_put(tenant_url, tenant, event_id)

    [tenant, provider]
  rescue ActiveRecord::RecordNotFound
    [{ id: event.tenant_id }, nil]
  end

  def provider_endpoint(provider)
    root_url = config.root_url
    return root_url if root_url

    # This is far for perfect, but there is no request in workers to infer the domain from.
    options = { host: provider.external_admin_domain }
    options.reverse_merge!(Rails.env.development? ? { port: 3000 } : ActionMailer::Base.default_url_options)
    System::UrlHelpers.system_url_helpers.root_url(options)
  end

  delegate :provider_access_token, to: :class

  def self.provider_access_token(provider)
    user = provider.find_impersonation_admin || provider.first_admin!

    user.access_tokens.oidc_sync.value
  end

  def notification_url
    URI.join(endpoint, 'notification')
  end

  def http_put(url, body, event_id)
    headers = JSON_REQUEST.merge('X-Event-Id' => event_id).merge(authorization_headers)
    response = http_client.put url, body.to_json, headers

    raise UnprocessableEntityError, response if response.status == 422

    raise InvalidResponseError, response unless response.ok?

    response
  end

  NO_AUTH = {}.freeze
  private_constant :NO_AUTH

  def authorization_headers
    return NO_AUTH unless authentication

    token = authentication.with_indifferent_access.fetch(:token) { return NO_AUTH }

    { 'Authorization' => ActionController::HttpAuthentication::Token.encode_credentials(token) }
  end

  def tenant_url
    URI.join(endpoint, 'tenant')
  end

  delegate :config, to: :class
  delegate :endpoint, to: :config
  delegate :authentication, to: :config

  JSON_REQUEST = { 'Content-Type' => 'application/json' }.freeze

  def retry_identifier
    "#{self.class.name} for event_id #{event_id}"
  end
end
