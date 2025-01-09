# frozen_string_literal: true

class Provider::Admin::User::AccessTokensNewPresenter

  def initialize(provider)
    @timezone = ActiveSupport::TimeZone.new(provider.timezone)
  end

  def provider_timezone_offset
    @timezone.utc_offset
  end
end
