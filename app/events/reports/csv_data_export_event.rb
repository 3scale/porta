class Reports::CsvDataExportEvent < ReportRelatedEvent
  def self.create(provider, recipient, type, period)
    new(
      provider:  provider,
      recipient: recipient,
      type:      type,
      period:    period.presence || 'all'.freeze,
      metadata: {
        provider_id: provider.id
      }
    )
  end
end
