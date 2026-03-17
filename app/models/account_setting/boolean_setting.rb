# frozen_string_literal: true

class AccountSetting::BooleanSetting < AccountSetting
  self.non_null = true

  def self.cast(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def self.serialize(value)
    value ? "1" : "0"
  end

  def typed_value
    self.class.cast(value)
  end

  def toggle_value!
    new_value = !typed_value
    self.value = self.class.serialize(new_value)
    save!
    new_value
  end
end
