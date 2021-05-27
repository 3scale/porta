# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = Rails.configuration.three_scale.bugsnag_api_key
  config.app_version = System::Deploy.info.revision
  config.notify_release_stages = %w[production]
  stages = Rails.configuration.three_scale.error_reporting_stages
  config.notify_release_stages = stages if stages.present?

  ignore_error_names = ActionDispatch::ExceptionWrapper.rescue_responses.keys + ['WebHookWorker::ClientError']

  config.ignore_classes << ->(error) do
    ignore_error_names.include?(error.class.name)
  end

  config.ignore_classes << ->(error) do
    error.is_a?(Liquid::SyntaxError) && error.message.include?("Unknown tag 'do_not_send'")
  end
end
