# frozen_string_literal: true

module AccountSettings
  class CachedRetrievalService < ThreeScale::Patterns::Service
    NOT_SET = Object.new.freeze
    private_constant :NOT_SET

    # @param account [Account] the account to retrieve settings for
    # @param setting_name [String] the name of the setting (e.g., 'permissions_policy_header_admin', 'permissions_policy_header_developer')
    # @param value [String, nil] when provided, writes this value to cache instead of fetching
    # @param expires_in [ActiveSupport::Duration] cache expiration time (default: 10 minutes)
    def initialize(account:, setting_name:, value: NOT_SET, expires_in: 10.minutes)
      @account = account
      @setting_name = setting_name.to_s
      @value = value
      @expires_in = expires_in
    end

    # @return [String, nil] the setting value or default value
    def call
      key = "account:#{@account.id}:#{@setting_name}"

      if @value.equal?(NOT_SET)
        Rails.cache.fetch(key, expires_in: @expires_in) do
          settings = @account.account_settings.to_a
          setting = settings.find { |s| s.setting_name == @setting_name }

          setting ? setting.value : setting_class.default_value
        end
      else
        Rails.cache.write(key, @value, expires_in: @expires_in)
        @value
      end
    end

    private

    def setting_class
      @setting_class ||= AccountSetting.class_for_setting(@setting_name)
    end
  end
end
