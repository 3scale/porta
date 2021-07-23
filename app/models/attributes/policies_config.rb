# frozen_string_literal: true

class Attributes::PoliciesConfig < ActiveRecord::Type::Text
  def cast(value)
    Proxy::PoliciesConfig.new(value)
  end

  def serialize(value)
    value.to_json
  end

  def changed_in_place?(raw_old_value, new_value)
    new_value != cast(raw_old_value)
  end
end
