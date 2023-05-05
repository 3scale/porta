# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = Rails.configuration.three_scale.bugsnag_api_key
  config.app_version = System::Deploy.info.revision
  stages = Rails.configuration.three_scale.error_reporting_stages
  # TODO: after upgrading Bugsnag replace `notify_release_stages` (deprecated in v6.23) with `enabled_release_stages`
  # see https://github.com/bugsnag/bugsnag-ruby/releases/tag/v6.23.0
  config.notify_release_stages = stages.present? ? stages : %w[staging production]
  config.release_stage = Rails.configuration.three_scale.bugsnag_release_stage || Rails.env

  ignore_error_names = ActionDispatch::ExceptionWrapper.rescue_responses.keys + ['WebHookWorker::ClientError']

  config.ignore_classes << ->(error) do
    ignore_error_names.include?(error.class.name)
  end

  config.ignore_classes << ->(error) do
    error.is_a?(Liquid::SyntaxError) && error.message.include?("Unknown tag 'do_not_send'")
  end

  config.logger.level = Logger::ERROR if config.api_key.nil?
end
