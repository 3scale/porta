# frozen_string_literal: true

class AccountSetting::CspReportOnlyHeaderAdmin < AccountSetting::HttpHeader
  def self.display_name = "Content-Security-Policy-Report-Only Header"

  def self.build_default_value
    asset_host = Rails.configuration.asset_host.presence

    sources = {
      default_src:     ["'self'"],
      script_src:      ["'self'", "'unsafe-inline'", "'unsafe-eval'", asset_host].compact,
      style_src:       ["'self'", "'unsafe-inline'", asset_host].compact,
      font_src:        ["'self'", "data:", asset_host].compact,
      img_src:         ["'self'", "data:", "blob:", "https:", asset_host].compact,
      connect_src:     ["*"],
      frame_src:       ["'self'"],
      frame_ancestors: ["'none'"],
      object_src:      ["'none'"],
      base_uri:        ["'self'"]
    }

    if Rails.env.development?
      webpack = ["localhost:3035", "ws://localhost:3035"]
      sources[:script_src]  += webpack
      sources[:style_src]   += webpack
      sources[:font_src]    += webpack
      sources[:img_src]     += webpack
      sources[:connect_src] += webpack
    end

    sources.map { |directive, values| "#{directive.to_s.tr('_', '-')} #{values.join(' ')}" }.join("; ")
  end

  self.default_value = build_default_value
end
