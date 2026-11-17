# frozen_string_literal: true

class AccountSetting::CMSEscapePublishedHtml < AccountSetting::BooleanSetting
  attribute :value, default: true
end
