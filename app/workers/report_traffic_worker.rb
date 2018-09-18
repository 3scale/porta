# Report MT API traffic usage to 3scale backend.
#
# It sends info about:
#  - app_id: Id of master application.
#  - usage:  API section consumed. Ex: account, billing, stats.
#  - log:    Request and response info.

begin
  require '3scale/client'
rescue LoadError
  Rails.configuration.three_scale.report_traffic = false
end

class ReportTrafficWorker
  class ReportTrafficError < StandardError
    include Bugsnag::MetaData

    def initialize(response)
      super "Server error while trying to report traffic (#{response.code})"
      self.bugsnag_meta_data = {
        response: response.inspect,
      }
    end
  end

  include Sidekiq::Worker
  sidekiq_options queue: :low

  DISCARD_CODES = 200...300

  class << self
    def enqueue(account, metric_system_name, request, response)
      return unless enabled?
      return unless account

      args = [
        account.id,
        metric_system_name,
        filter_request_attrs(request),
        filter_response_attrs(response),
        Time.now.to_i
      ]

      perform_async(*args)
    end

    private

    def enabled?
      Rails.configuration.three_scale.report_traffic
    end

    def filter_request_attrs(request)
      {
        path:      request.fullpath,
        method:    request.method,
        remote_ip: request.remote_ip,
        headers:   request.headers.select { |k, v| k =~ /HTTP_/ },
      }
    end

    def filter_response_attrs(response)
      {
        code:   response.status,
        length: response.body.length,
        body:   (DISCARD_CODES.cover?(response.status) ? "discarded" : response.body),
      }
    end
  end

  def perform(account_id, metric_system_name, request, response, timestamp = Time.now)
    time = Time.at(timestamp)
    application_id = master_application_id(account_id)
    return unless application_id && master_service_metric?(metric_system_name.to_s)

    transactions = {
      app_id: application_id,
      usage:  { metric_system_name => 1 },
      log:    report_traffic_log(request, response),
      timestamp: time.utc.to_s
    }

    client.report(transactions)
  rescue ThreeScale::ServerError => exception
    raise ReportTrafficError, exception.response
  end

  private

  def client
    @client ||= ThreeScale::Client.new(System::Application.config.backend_client.merge(
                                        provider_key: master_service.account.api_key))
  end

  def master_service
    @master_service ||= Service.where(account_id: Account.master_id).first
  end

  def master_application_id(account_id)
    Cinstance.joins(:plan)
      .where(user_account_id:  account_id)
      .merge(Plan.where(issuer: master_service))
      .first!.application_id
  end

  def master_service_metric?(metric_system_name)
    Metric.exists?(system_name: metric_system_name, service_id: master_service.id)
  end

  def report_traffic_log(request, response)
    {
      request:  request,
      response: response,
      code:     response.symbolize_keys[:code],
    }
  end
end
