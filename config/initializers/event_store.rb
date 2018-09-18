System::Application.configure do
  config = self.config

  ActionDispatch::Reloader.to_prepare { config.event_store = EventStore::Repository.new }
end
