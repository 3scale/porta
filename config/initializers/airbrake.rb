# Disable Airbrake if it is not configured
# https://github.com/airbrake/airbrake/issues/546#issue-153141267
if defined?(Airbrake) && Rails.configuration.three_scale.airbrake_api_key.present?
  Airbrake.configure do |config|
    config.api_key = Rails.configuration.three_scale.airbrake_api_key

    # new airbrake backend, should be more reliable
    config.host = 'api.airbrake.io'

    # This error is mostly caused by various spammers and robots crawling the site like crazy.
    # We don't need to be bothered by it.
    config.ignore << 'ActionController::MethodNotAllowed'

    # various attempts with HTTP methods (SEARCH/CONNECT/NESSUS)
    config.ignore << 'ActionController::UnknownHttpMethod'

    # when WebHooks fails because the remote is down or similar - we don't mind
    config.ignore << 'WebHookJob::ClientError'

    config.ignore << 'Rack::Utils::ParameterTypeError'
    config.ignore << 'ActionDispatch::ParamsParser::ParseError'

    config.ignore << 'ZyncWorker::UnprocessableEntityError'

    stages = Rails.configuration.three_scale.error_reporting_stages
    config.development_environments = %w[development test cucumber]
    config.development_environments |= [Rails.env.to_s] if stages.exclude?(Rails.env.to_s)

    config.user_information = "<p>Tell the support it was error {{ error_id }}.</p>"
  end
end
