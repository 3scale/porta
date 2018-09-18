class Reports::ReportBaseEvent < ReportRelatedEvent
  # @param [Pdf::Report] report
  def self.create(report)
    new(
      account: account = report.account,
      service: report.service,
      period: report.period,
      metadata: {
        provider_id: account.id
      }
    )
  end
end
