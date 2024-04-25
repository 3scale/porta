# frozen_string_literal: true

class EventImportWorker
  include Sidekiq::Job

  def perform(attributes)
    Events::Importer.import_event!(attributes)
  end
end
