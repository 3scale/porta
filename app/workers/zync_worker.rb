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
      when 'Application' then Cinstance
      else name.constantize
      end
    end

    GlobalID::Locator.use(:zync, Locator)
  end

  module MessageBusInstrumentation
    def publish(channel, data, options = {})
      id = super
    ensure
      logger.info "[MessageBus] published #{channel} #{data.to_json} (#{options}) with id #{id}"
    end
  end

  Notification = Struct.new(:record, :version, :payload) do
    delegate :to_gid_param, to: :record
    delegate :as_json, to: :payload

    def channel
      [ '/integration', to_gid_param, version ].compact.join('/')
    end
  end

  class MessageBusPublisher
    include ActiveSupport::Benchmarkable
    delegate :logger, to: :Sidekiq

    attr_reader :notification

    class_attribute :enabled, instance_accessor: false, instance_predicate: false
    self.enabled = ZyncWorker.config.message_bus

    def initialize(notification)
      @notification = notification.nested_under_indifferent_access
    end

    def channel
      "/integration/#{record.to_param}"
    end

    def record
      gid = URI::GID.build(app: 'zync', model_name: notification.fetch('type'), model_id: notification.fetch('id').to_s)
      GlobalID.new(gid)
    end

    def enabled?
      return unless self.class.enabled

      case record.model_name
      when 'Proxy' then true
      else false
      end
    end

    def self.locate(uri)
      Locator.locate(GlobalID.parse(uri))
    end

    def self.transform_message(message)
      record = locate(message.fetch('record'))

      lock_version = message.dig('entry_data', 'lock_version')
      payload = message.slice('exception_object', 'success')

      ZyncWorker::Notification.new(record, lock_version, payload)
    end

    def self.build_publisher_bus(provider)
      message_bus = MessageBus::Instance.new
      message_bus.config.merge!(MessageBus.config)
      message_bus.extend(MessageBusInstrumentation)

      message_bus.site_id_lookup { provider.to_gid_param }

      message_bus
    end

    delegate :build_publisher_bus, :transform_message, to: :class

    def handle_incoming_message(message, provider)
      message_bus = build_publisher_bus(provider)

      msg = transform_message(message)
      message_bus.publish msg.channel, msg.as_json, group_ids: [ provider.id ]
    end

    def log_message_processing(message)
      record = GlobalID.parse(message.fetch('record'))

      logger.info { "[ZyncWorker] received message #{message} for #{record}" }

      yield

      logger.info { "[ZyncWorker] handled message for #{record}, stopping the client" }
    end

    def handle_message(provider, queue, message)
      log_message_processing(message) do
        queue.push handle_incoming_message(message, provider)
        queue.close # close the queue as we wanted only one message
      end
    rescue ClosedQueueError
      # we want to re-raise ClosedQueueError so it crashes the message bus client
      # otherwise it would wait for the pool time to close the connection

      raise
    rescue => error
      System::ErrorReporting.report_error(error, logger: Sidekiq.logger)
      raise
    end

    def message_handler(provider, queue)
      method(:handle_message).curry.call(provider, queue)
    end

    def call(client, provider)
      return yield unless enabled?

      queue = SizedQueue.new(1)

      client.subscribe(channel, &message_handler(provider, queue))

      started = client.start

      yield

      wait_for(queue)
    ensure
      if started
        benchmark 'Stop MessageBusClient', level: :info do
          client.stop(0.1)
        end
      end
    end

    class MessageBusTimeoutError < Timeout::Error
      def initialize(_)
        super 'Timeout when waiting for MessageBus Message'
      end
    end

    Bugsnag::Middleware::ClassifyError::INFO_CLASSES << MessageBusTimeoutError.to_s

    def wait_for(queue, timeout: MessageBusClient.poll_interval * 4.5)
      # Using Timeout.timeout is technically unsafe, but in this case it just waits on a queue
      # So it should be safe in this cases as the thread does nothing else than wait on the queue.
      Timeout.timeout(timeout, MessageBusTimeoutError) do
        benchmark 'Wait for MessageBus Message', level: :info do
          queue.pop
        end
      end
    end
  end

  def message_bus_client(tenant)
    uri = URI(endpoint)
    uri.userinfo = format('%s:%s', *tenant.values_at(:id, :access_token))

    MessageBusClient.new(uri)
  end

  def perform(event_id, notification, manual_retry_count = nil)
    return false unless valid?(event_id)
    event = EventStore::Repository.find_event!(event_id)

    with_manual_retry_count(event_id, manual_retry_count) do
      tenant, provider = update_tenant(event)

      publish_notification = -> { http_put(notification_url, notification, event_id) }

      if provider # tenant is still there
        client = message_bus_client(tenant)
        MessageBusPublisher.new(notification).call(client, provider, &publish_notification)
      else
        publish_notification.call
      end
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
    perform_async(event.event_id, event.data, manual_retry_count)
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

    [ tenant, provider ]
  rescue ActiveRecord::RecordNotFound
    [ { id: event.tenant_id }, nil ]
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

    { 'Authorization' =>  ActionController::HttpAuthentication::Token.encode_credentials(token) }
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
