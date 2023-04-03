require_or_load 'backend/error'

ThreeScale::Core::Logger.inject Rails.logger, prefix: '[core]'
