# frozen_string_literal: true

module Pdf
  class Dispatch
    # For dispatching reports: daily and weekly. A cron job is required for each period.
    # Pdf::Dispatch.weekly to send reports out for week period
    # Pdf::Dispatch.daily to send reports out for day period

    def self.weekly
      enqueue_reports(:week)
    end

    def self.daily
      enqueue_reports(:day)
    end

    private_class_method

    def self.enqueue_reports(period)
      Service.accessible.of_approved_accounts.select(%i[id account_id]).find_each do |service|
        PdfReportWorker.enqueue(service, period)
      end
    end
  end
end
