# frozen_string_literal: true

class Attributes::PoliciesConfig < ActiveRecord::Type::Text
  def cast(value)
    if :oracle == System::Database.adapter.to_sym && value.is_a?(ActiveRecord::OracleEnhanced::Type::Text::Data)
      value = value.to_s
    end
    Proxy::PoliciesConfig.new(value)
  end

  def serialize(value)
    if :oracle == System::Database.adapter.to_sym
      ActiveRecord::OracleEnhanced::Type::Text::Data.new(value.presence&.to_json)
    else
      value.to_json
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    new_value != cast(raw_old_value)
  end
end
