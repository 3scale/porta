require 'httpclient/include_client'

class Apicast::Sandbox
  extend ::HTTPClient::IncludeClient
  include ::ThreeScale::MethodTracing

  def self.config
    ThreeScale.config.sandbox_proxy
  end

  include_http_client do |client|
    client.debug_dev = $stdout if config.debug
    client.connect_timeout = 30
    client.receive_timeout = 30
    client.send_timeout = 10
  end

  protected :http_client

  attr_reader :provider_id, :secret, :hosts

  attr_accessor :raise_exceptions

  def initialize(provider, config)
    @provider_id = provider.id
    @secret = config[:shared_secret]
    @hosts = config[:hosts].freeze

    if @secret.nil? || @hosts.nil?
      raise ArgumentError, "Invalid sandbox proxy config: #{config.inspect}"
    end
  end

  # We don't send any code because LUA files are
  # shipped beforehand to s3 and fetched by the sandbox proxy hosts.
  def deploy
    return true if self.class.config.skip_deploy

    deployments = hosts.map(&method(:start_deploy))

    finished, failures = deployments.partition(&method(:wait_for_deploy))

    finished.each(&method(:report_success))

    successful = HTTP::Status.method(:successful?)

    failures.none? && finished.map(&:status).all?(&successful)
  end

  add_three_scale_method_tracer :deploy, 'External/Proxy::Sandbox#deploy'

  protected

  Deployment = Struct.new(:started, :request) do
    attr_accessor :response, :finished

    delegate :status, to: :response, allow_nil: true
  end
  private_constant :Deployment

  # @return [Deployment]
  def start_deploy(host)
    url = "http://#{host}/deploy/#{secret}"
    Rails.logger.debug "[sandbox-proxy] Deploying via #{url}"

    Deployment.new(
      Time.now.to_f,
      http_client.get_async(url, provider_id: provider_id)
    )
  end

  def report_success(deployment)
    time = deployment.finished - deployment.started
    Rails.logger.info "[sandbox-proxy] Deployed sandbox proxy for provider #{provider_id} in #{time.round(4)}s"
  end

  # @param deployment [Deployment]
  # @return [HTTP::Message]
  def wait_for_deploy(deployment)
    connection = deployment.request.tap(&:join)
    response = connection.pop
    deployment.finished = Time.now.to_f
    deployment.response = response
  rescue => error
    msg = "Failed to deploy sandbox proxy for provider #{provider_id} with #{error}: #{error.message}"
    Rails.logger.error "[sandbox-proxy]: #{msg}"
    System::ErrorReporting.report_error error_class: error, error_message: msg
    raise if raise_exceptions
  end
end
