# frozen_string_literal: true

class PdfReportWorker
  include Sidekiq::Job

  sidekiq_options queue: :low, retry: false, backtrace: true

  # @param [Symbol] period :week or :day
  # @param [Account] account
  def self.enqueue(service, period)
    perform_async(service.id, service.account_id, period.to_s)
  end

  # @param [Integer] service_id
  # @param [Integer] account_id
  # @param [String] period
  def perform(service_id, account_id, period)
    provider = Provider.find(account_id)
    service = provider.accessible_services.find(service_id)

    report = Pdf::Report.new(provider, service, period: period.to_sym)

    notification = provider.admins.includes(:notification_preferences).any? do |user|
      report.deliver_notification?(user)
    end

    if notification
      report.generate.send_notification!
    else
      logger.info "[PdfReportWorker] Skipping report for Service #{service_id} of Account #{account_id}"
    end
  end

  delegate :logger, to: :Rails
end
