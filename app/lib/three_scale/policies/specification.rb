# frozen_string_literal: true

module ThreeScale
  module Policies
    class Specification
      def initialize(doc)
        @errors = ActiveModel::Errors.new(self)
        @doc = doc
        @validator = JSONValidator.new(doc)
      end

      attr_reader :errors, :doc

      JSON_SCHEMA = {'$ref' => 'http://apicast.io/policy-v1/schema#'}.freeze

      def valid?
        return false if errors.any?
        @validator.fully_validate(JSON_SCHEMA).each { |error| errors.add(:base, error) }
        errors.empty?
      end
    end
  end
end
