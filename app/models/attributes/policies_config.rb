class Attributes::PoliciesConfig < ActiveRecord::Type::Text
  def cast(value)
    if value.is_a?(Proxy::PoliciesConfig)
      value
    else
      Proxy::PoliciesConfig.new(value)
    end
  end

  def serialize(value)
    value.to_json
  end

  def changed_in_place?(raw_old_value, new_value)
    new_value != cast(raw_old_value)
  end
end
