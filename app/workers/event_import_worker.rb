require_dependency 'events/importer'

class EventImportWorker
  include Sidekiq::Worker

  def perform(attributes)
    Events::Importer.import_event!(attributes)
  end
end
