# frozen_string_literal: true

module ThreeScale
  class JSONValidator < ::JSON::Validator
    # Register new schema files/globs here to automatically load them on startup
    # or add them manually later with ThreeScale::JSONValidator.add_schema(schema)
    AUTOLOAD_SCHEMA_FILES  = [
      'app/lib/three_scale/swagger/schemas/*.schema.json',
      'app/lib/three_scale/swagger/schemas/1.2/*.json',
      'app/lib/three_scale/policies/schemas/*.schema.json'
    ].freeze
    private_constant :AUTOLOAD_SCHEMA_FILES

    def self.autoload_schemas
      autoloaded_schema_files.each do |file|
        begin
          schema_json = JSON.parse(File.read(file))
          add_schema(build_schema(schema_json))
        rescue StandardError => error
          Rails.logger.info("** Failed to register schema: #{file} -- #{error}")
        end
      end
    end

    def self.build_schema(schema_json)
      JSON::Schema.new(schema_json, schema_id(schema_json))
    end

    def initialize(json, schema_reader_options = {})
      @json = json
      @schema_reader = build_schema_reader(schema_reader_options)
    end

    attr_reader :json, :schema_reader

    def fully_validate(schema, opts = {})
      options = opts.reverse_merge(schema_reader: schema_reader)
      ::JSON::Validator.fully_validate(schema, json, options)
    end

    private

    class << self
      private

      def autoloaded_schema_files
        AUTOLOAD_SCHEMA_FILES.map { |glob| Dir.glob(glob) }.flatten
      end

      def schema_id(schema_json)
        # https://json-schema.org/understanding-json-schema/basics.html#declaring-a-unique-identifier
        attr = schema_draft(schema_json) <= 4 ? 'id' : '$id'
        schema_json[attr]
      end

      def schema_draft(schema_json)
        schema_json['$schema'].to_s.slice(%r{/draft-(\d{2})/}, 1).to_i
      end
    end

    SCHEMA_READER_DEFAULT = { accept_uri: false, accept_file: false }.freeze
    private_constant :SCHEMA_READER_DEFAULT

    def build_schema_reader(opts = {})
      options = opts.reverse_merge(SCHEMA_READER_DEFAULT)
      JSON::Schema::Reader.new(options)
    end
  end
end

ThreeScale::JSONValidator.autoload_schemas
