# frozen_string_literal: true

module ContentSecurityPolicy
  def self.setup_policy(asset_host)
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
