module ThreeScale

  class LocalhostValidator < ActiveModel::EachValidator

    LOCALHOST = 'localhost'.freeze

    def validate_each(record, attribute, value)
      errors = record.errors
      uri = Addressable::URI.parse(value)

      return unless uri

      errors.add(attribute, :localhost) if uri.host == LOCALHOST
    rescue Addressable::URI::InvalidURIError
      errors.add(attribute, :invalid_url)
    end
  end
end
