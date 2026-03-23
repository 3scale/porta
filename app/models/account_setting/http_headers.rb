# frozen_string_literal: true

class AccountSetting::HttpHeaders < AccountSetting
  validates :value,
            length: { maximum: 5000 },
            format: {
              with: /\A[\x20-\x7E]*\z/n,
              message: 'RFC 7230 allows only printable ASCII header values',
              allow_blank: true
            }
end
