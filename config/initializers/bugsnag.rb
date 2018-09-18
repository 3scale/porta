Bugsnag.configure do |config|
  config.api_key = Rails.configuration.three_scale.bugsnag_api_key
  config.app_version = System::Deploy.info.revision
  config.notify_release_stages = %w[production]
  stages = Rails.configuration.three_scale.error_reporting_stages
  config.notify_release_stages = stages if stages.present?

  # when WebHooks fails because the remote is down or similar - we don't mind
  config.ignore_classes << WebHookWorker::ClientError
end
