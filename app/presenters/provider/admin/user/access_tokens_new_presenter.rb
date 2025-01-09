# frozen_string_literal: true

class Provider::Admin::User::AccessTokensNewPresenter

  def initialize(provider)
    @timezone = ActiveSupport::TimeZone.new(provider.timezone)
  end

  def provider_timezone_offset
    @timezone.utc_offset
  end

  def date_picker_props
    {
      id: 'access_token[expires_at]',
      label: I18n.t('access_token_options.expires_in'),
      tzOffset: provider_timezone_offset
    }
  end
end
