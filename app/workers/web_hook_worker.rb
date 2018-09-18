# frozen_string_literal: true

class WebHookWorker
  include Sidekiq::Worker
  include ThreeScale::SidekiqRetrySupport::Worker
  HANDLED_ERRORS = [
    SocketError, RestClient::Exception,
    Errno::ECONNREFUSED, Errno::ECONNRESET
  ].freeze

  sidekiq_options queue: :web_hooks, retry: 5, dead: false

  sidekiq_retry_in do |_count|
    Rails.env.development? ? 1.second : 1.minute
  end

  sidekiq_retries_exhausted do |job, exception|
    webhook_id, options = job['args']
    options.symbolize_keys!

    WebHookFailures.add(options[:provider_id], exception, webhook_id, options[:url], options[:xml])
    Sidekiq.logger.info { "#{retry_identifier(webhook_id)} added to failures" }
  end

  class Error < ::StandardError; end

  class ClientError < Error
    def initialize(client_error)
      @client_error = client_error
    end

    def message
      @client_error.message
    end
  end

  attr_reader :webhook_id

  # 'options' (Hash) is expected to have the following keys:
  # - :provider_id (so an eventual WebHook::Failure can be stored)
  # - :url
  # - :xml
  # - :content_type (optional)
  def perform(webhook_id, options)
    @webhook_id = webhook_id

    with_retry_count do
      push(options.symbolize_keys.slice(:url, :xml, :content_type))
    end
  end

  def push(url:, xml:, content_type: nil)
    if content_type
      RestClient.post(url, xml, :content_type => content_type)
    else
      RestClient.post(url, :params => { :xml => xml })
    end
  rescue *HANDLED_ERRORS
    # Normally, we would just ignore the client side errors but we
    # need for the job to fail and then retry, so it has to crash
    # hard.
    #
    # Nonetheless, the exception is wrapped so that it can be
    # ignored by Airbrake/Bugsnag.
    raise WebHookWorker::ClientError.new($!)
  end

  def retry_identifier
    self.class.retry_identifier(webhook_id)
  end

  def self.retry_identifier(id)
    "WebHook(#{id})"
  end
end
