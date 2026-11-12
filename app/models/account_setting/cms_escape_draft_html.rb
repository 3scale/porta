# frozen_string_literal: true

class AccountSetting::CMSEscapeDraftHtml < AccountSetting::BooleanSetting
  attribute :value, default: true
end
