# frozen_string_literal: true

class AccountSetting::HttpHeader < AccountSetting
  # The value keeps the column's (CLOB) type: Oracle binds a declared :string or :text type as VARCHAR2, which turns ''
  # into NULL and limits it to 4000 bytes
  MAX_LENGTH = 5000

  validates :value,
            length: { maximum: MAX_LENGTH },
            format: {
              with: /\A[\x20-\x7E]*\z/n,
              message: 'RFC 7230 allows only printable ASCII header values',
              allow_blank: true
            }

  after_commit :refresh_cache

  private

  def refresh_cache
    cached_value = destroyed? ? default_value : value
    AccountSettings::SettingCache.set(account: account, setting_name: setting_name, value: cached_value)
  end
end
