# frozen_string_literal: true

module ThreeScale
  class JSONValidator < ::JSON::Validator
    def self.setup!
      self.schema_reader = JSON::Schema::Reader.new(accept_uri: false, accept_file: false)
    end

    def self.setup
      setup!
    rescue StandardError => error
      Rails.logger.info("Failed to setup JSON Validator: #{error}")
      nil
    end
  end
end
