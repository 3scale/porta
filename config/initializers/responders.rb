# frozen_string_literal: true

require 'responders'

# Configure responders gem for Rails 7
# This is needed because ActionController::Responder was extracted to the responders gem
Rails.application.config.to_prepare do
  ApplicationController.include Responders::ControllerMethod
end