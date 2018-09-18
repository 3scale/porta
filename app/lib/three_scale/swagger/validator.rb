# Swagger validations by apigee: https://github.com/apigee-127/swagger-tools/blob/master/docs/Swagger_Validation.md
#
module ThreeScale

  module Swagger

    class Validator < ActiveModel::Validator


      def validate record
        valid_base_path?(record)
        validate_specification(record)
        # KeyError -- json hash does not contain 'apis' key
        # TypeError - parsed json is not a Hash
      rescue KeyError, TypeError => error
        record.errors.add :body, :invalid_swagger
      rescue JSON::ParserError => error
        record.errors.add :body, :invalid_json
      end

      def validate_specification record
        return if record.skip_swagger_validations

        specification = record.specification

        unless specification.valid?
          specification.errors[:base].uniq.each do |message|
            record.errors.add :body, message
          end
        end
      end

      # based on http://gist.github.com/bf4/5320847
      def valid_base_path?(record)
        # https://github.com/3scale/system/issues/4080
        return true if record.specification.base_path.blank?
        uri = self.class.parse_uri record.specification.base_path
        return true if uri && ["https", "http"].include?(uri.scheme)
        record.errors.add :base_path, :invalid
        false
      end

      def self.parse_uri(value)
        uri = Addressable::URI.parse(value)
        uri if uri && uri.scheme && uri.host
      rescue URI::InvalidURIError, Addressable::URI::InvalidURIError, TypeError
      end

    end
  end
end

