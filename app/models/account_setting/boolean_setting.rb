# frozen_string_literal: true

class AccountSetting::BooleanSetting < AccountSetting
  self.non_null = true
  self.default_value = false
  attribute :value, :boolean, default: false

  def toggle_value!
    self.value = !value
    save!
    value
  end
end
