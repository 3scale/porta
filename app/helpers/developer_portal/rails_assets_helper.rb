# frozen_string_literal: true

module DeveloperPortal::RailsAssetsHelper
  def rails_asset_host_url
    asset_host_url = Rails.configuration.three_scale.asset_host.presence
    return '' unless asset_host_url
    return asset_host_url if asset_host_url.match? %r{^https?://}

    "#{request.protocol}#{asset_host_url}"
  end
end
