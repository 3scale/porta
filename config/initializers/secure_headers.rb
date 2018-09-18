::SecureHeaders::Configuration.configure do |config|
  config.hsts = false
  config.x_frame_options = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = { value: 1, mode: 'block' }

  config.csp = false

  # not sure what they do, so rather disabling them
  config.x_download_options = false
  config.x_permitted_cross_domain_policies = false
end
