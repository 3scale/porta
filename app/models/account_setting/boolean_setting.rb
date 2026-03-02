# frozen_string_literal: true

class AccountSetting::BooleanSetting < AccountSetting
  def self.cast(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def self.serialize(value)
    value ? "1" : "0"
  end

  def typed_value
    self.class.cast(value)
  end
end
