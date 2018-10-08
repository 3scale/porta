# frozen_string_literal: true

class NonLocalhostValidator < ActiveModel::EachValidator

  LOCALHOST = /\A(localhost|127(\.\d{1,3}){3})\Z/

  def validate_each(record, attribute, value)
    errors = record.errors
    uri = Addressable::URI.parse(value)

    return unless uri

    errors.add(attribute, options[:message] || :localhost) if uri.host =~ LOCALHOST
  rescue Addressable::URI::InvalidURIError
    errors.add(attribute, :invalid_url)
  end
end
