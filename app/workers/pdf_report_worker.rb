class PdfReportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low, retry: false, backtrace: true

  # @param [Symbol] period :week or :day
  # @param [Account] account
  # @param [SystemOperation] system_operation
  def self.enqueue(service, period, system_operation)
    perform_async(service.id, service.account_id, period, system_operation.ref)
  end

  # @param [Integer] service_id
  # @param [Integer] account_id
  # @param [String] period
  # @param [String] reference
  def perform(service_id, account_id, period, reference)
    operation = SystemOperation.for(reference)
    provider = Provider.find(account_id)
    service = provider.accessible_services.find(service_id)

    report = Pdf::Report.new(provider, service, period: period.to_sym)

    dispatch = provider.mail_dispatch_rules.enabled.exists?(system_operation: operation)
    notification = provider.admins.includes(:notification_preferences).any? do |user|
      report.deliver_notification?(user)
    end

    case
    when dispatch
        report.generate.mail_report
    when provider.provider_can_use?(:new_notification_system) && notification
        report.generate.send_notification!
    else
        logger.info "[PdfReportWorker] Skipping report for Service #{service_id} of Account #{account_id}"
    end
  end

  delegate :logger, to: :Rails
end

if Rails.application.config.three_scale.daily_weekly_reports_pref
  require_dependency 'pdf/report'
end
