System::Application.configure do
  config = self.config

  ActiveSupport::Reloader.to_prepare { config.event_store = EventStore::Repository.new }
end
