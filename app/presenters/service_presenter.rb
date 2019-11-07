# frozen_string_literal: true

class ServicePresenter < SimpleDelegator
  def as_json(*)
    {service: stringify_nil_values(filtered_values)}.merge(error_messages)
  end

  private

  def filtered_values
    __getobj__.as_json(root: false, only: %i[name system_name description])
  end

  def error_messages
    {errors: __getobj__.errors.messages.presence || {} }
  end

  def stringify_nil_values(hash)
    hash.transform_values(&:to_s)
  end
end
