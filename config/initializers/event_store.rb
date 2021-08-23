Rails.configuration.to_prepare do
  require 'rails_event_store'

  System::Application.configure do
    config = self.config
    config.event_store = EventStore::Repository.new
  end
end
