# frozen_string_literal: true

module ThreeScale
  module Policies
    class Specification
      extend ActiveModel::Naming
      extend ActiveModel::Translation

      def initialize(body)
        @errors = ActiveModel::Errors.new(self)

        begin
          @doc = JSON.parse(body.to_s)
        rescue JSON::ParserError
          @errors.add(:base, :invalid_json)
        end

        @doc ||= {}
      end

      attr_reader :errors, :doc

      JSON_SCHEMA = {'$ref' => 'http://apicast.io/policy-v1/schema#'}.freeze

      def valid?
        return false if errors.any?
        JSONValidator.fully_validate(JSON_SCHEMA, doc).each { |error| errors.add(:base, error) }
        errors.empty?
      end

      def self.setup_json_validator!
        JSONValidator.setup!

        schemas = Rails.root.join('app', 'lib', 'three_scale', 'policies', 'schemas', '*.schema.json')
        Dir.glob(schemas).each do |file|
          schema = JSON.parse(File.read(file))
          new_schema = JSON::Schema.new(schema, schema['$id'])
          JSONValidator.add_schema(new_schema)
        end
      end

      def self.setup_json_validator
        setup_json_validator!
      rescue StandardError => error
        Rails.logger.info("Failed to register schema with error: #{error}")
        nil

      end
    end
  end
end

ThreeScale::Policies::Specification.setup_json_validator
