require_or_load 'backend/errors'

ThreeScale::Core::Logger.inject Rails.logger, prefix: '[core]'
