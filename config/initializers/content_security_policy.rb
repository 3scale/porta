# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.to_prepare do
  asset_host = Rails.configuration.three_scale.asset_host.to_s.strip

  if Rails.env.test?
    Rails.application.config.content_security_policy do |policy|
      policy.default_src '*', :data, :mediastream, :blob, :filesystem, :ws, :wss, :unsafe_eval, :unsafe_inline
    end
  else
    Rails.application.config.content_security_policy do |policy|
      policy.default_src :self
      policy.font_src    :self, asset_host
      policy.img_src     :self, :data, asset_host
      policy.script_src  :self, :unsafe_inline, :unsafe_eval, asset_host
      policy.style_src   :self, :unsafe_inline, asset_host
      policy.connect_src '*'
    end
  end
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
