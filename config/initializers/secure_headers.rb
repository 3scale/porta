::SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{20.years.to_i}"
  config.x_frame_options = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = '1; mode=block'

  config.csp = {
    report_only:  true,
    default_src: %w(https: 'self')
  }

  # not sure what they do, so rather disabling them
  config.x_download_options = nil
  config.x_permitted_cross_domain_policies = 'none'
end
