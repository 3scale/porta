require 'action_dispatch/rails5_ssl'

# NOTE: The middleware is called before Threescale::Middleware::DevDomain
# So we only have the original host in request that is good
apicast_regexp = Regexp.compile(Rails.configuration.three_scale.apicast_internal_host_regexp.presence || '\A(?!.*)\Z'.freeze)
internal_request = ->(request) { apicast_regexp.match(request.host) }

# TODO: When migrated to Rails 5, we should remove this code as it is already built-in
if Rails.application.config.force_ssl
  Rails.application.config.middleware.swap ActionDispatch::SSL,
                                           ActionDispatch::Rails5SSL,
                                           {
                                             redirect: {
                                               exclude: internal_request
                                             }
                                           }
end
