# NOTE: The middleware is called before Threescale::Middleware::DevDomain
# So we only have the original host in request that is good

if Rails.application.config.force_ssl
  apicast_regexp = Regexp.compile(Rails.configuration.three_scale.apicast_internal_host_regexp.presence || '\A(?!.*)\Z'.freeze)
  internal_request = ->(request) { apicast_regexp.match(request.host) }
  Rails.application.config.ssl_options = { redirect: { exclude: internal_request } }
end
