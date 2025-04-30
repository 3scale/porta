# frozen_string_literal: true

module ThreeScale
  module Policies
    class Specification
      def initialize(doc)
        @errors = ActiveModel::Errors.new(self)
        @doc = doc
      end

      attr_reader :errors, :doc

      SCHEMAS_PATH = "app/lib/three_scale/policies/schemas/"
      POLICY_SCHEMAS_FILENAMES = %w[apicast-policy-v1.1.schema.json apicast-policy-v1.schema.json].freeze
      DEFAULT_POLICY_SCHEMA_ID = "http://apicast.io/policy-v1.1/schema"

      POLICY_SCHEMAS = POLICY_SCHEMAS_FILENAMES.each_with_object({}) do |schema_filename, schemas|
        policy_schema = JSON.parse(File.read(File.join(SCHEMAS_PATH, schema_filename)))
        schema_id = policy_schema["$id"]
        schemas[schema_id] = JSONSchemer.schema(policy_schema) if schema_id
      end.freeze

      def valid?
        return false if errors.any?

        schema_id = doc["$schema"] || DEFAULT_POLICY_SCHEMA_ID
        schemer = POLICY_SCHEMAS[schema_id]
        unless schemer
          errors.add(:base, "unsupported schema")
          return false
        end

        validate(schemer)

        errors.empty?
      end

      private

      def validate(schemer)
        schemer&.validate(doc).to_a.map { _1.fetch('error') }.each do |error|
          errors.add(:base, error)
        end
      rescue JSONSchemer::UnknownRef => exception
        errors.add(:base, "unknown ref: #{exception.message}")
      end
    end
  end
end
