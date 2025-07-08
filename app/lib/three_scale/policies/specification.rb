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
        id = policy_schema["$id"]
        schemas[id] = JSONSchemer.schema(policy_schema) if id
      end.freeze

      def valid?
        return false if errors.any?

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

      def schema_id
        @schema_id ||= begin
          schema = doc&.[]("$schema")
          # Stripping URL fragment for compatibility. Previously, the schema ID was defined as "http://apicast.io/policy-v1/schema#manifest",
          # or even "http://apicast.io/policy-v1/schema#manifest#"
          # After changing the validator to `json_schemer`, the schema ID is now defined as "http://apicast.io/policy-v1/schema"
          # to avoid issues with the existing schemas in the database or those coming from APIcast
          schema.present? ? UriUtils.strip_fragment(schema.sub(/\#$/, '')) : DEFAULT_POLICY_SCHEMA_ID
        end
      end
    end
  end
end
