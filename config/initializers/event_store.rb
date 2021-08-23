Rails.configuration.to_prepare do
  require 'rails_event_store'
  require 'three_scale/sidekiq_retry_support'

  System::Application.configure do
    config = self.config
    config.event_store = EventStore::Repository.new
  end
end
