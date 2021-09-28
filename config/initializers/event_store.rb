# 0.9.0 version of rails_event_store gem causes active_record to load pre-maturely
ActiveSupport.on_load(:active_record) do
  require 'rails_event_store'
  require 'three_scale/sidekiq_retry_support'

  System::Application.configure do
    config = self.config
    config.event_store = EventStore::Repository.new
  end
end
