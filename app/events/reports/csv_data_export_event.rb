# frozen_string_literal: true

class Reports::CsvDataExportEvent < ReportRelatedEvent
  # :reek:LongParameterList but there's no way around it
  def self.create(provider, recipient, type, period)
    new(
      provider:  provider,
      recipient: recipient,
      type:      type,
      period:    period,
      metadata: {
        provider_id: provider.id
      }
    )
  end
end
