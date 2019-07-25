# frozen_string_literal: true

class PathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :not_path_format) unless path?(value)
  end

  protected

  def path?(value)
    uri = URI.parse(value)
    uri.path == value
  rescue URI::InvalidURIError
    false
  end
end
