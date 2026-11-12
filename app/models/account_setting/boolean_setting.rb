# frozen_string_literal: true

class AccountSetting::BooleanSetting < AccountSetting
  attribute :value, :boolean, default: false

  def toggle_value!
    self.value = !value
    save!
    value
  end
end
