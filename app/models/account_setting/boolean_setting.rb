# frozen_string_literal: true

class AccountSetting::BooleanSetting < AccountSetting
  self.default_value = false
  attribute :value, :boolean, default: false

  def toggle_value!
    self.value = !value
    save!
    value
  end
end
