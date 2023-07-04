Rails.application.config.to_prepare do
  Events.shared_secret = Rails.configuration.three_scale.events_shared_secret
end
