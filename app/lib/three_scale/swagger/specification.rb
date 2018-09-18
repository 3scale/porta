module ThreeScale
  module Swagger
    class Specification

      class VBase
        def initialize(spec)
          @doc = spec.doc
          @errors = spec.errors
        end

        # The base path of the specification. This is needed to have it whitelisted on api_docs_proxy.
        def base_path
          @doc.fetch("basePath", nil).try(:downcase)
        end

        def validate!
          raise "#{self.class} should implement #{__method__}"
        end

        def swagger?
          raise "#{self.class} should implement #{__method__}"
        end

      end

      class VInvalid < VBase
        def validate!
          @errors.add(:base, :invalid_version)
        end

        def swagger?
          false
        end
      end


      class V20 < VBase

        # NOTE:
        #   * "If the schemes is not included, the default scheme to be used is the one used to access the specification."
        #   * "If the host is not included, the host serving the documentation is to be used (including the port)."
        # To acomplish this we return an empty string.
        # ApiDocsProxy supports only http/s
        def base_path
          schema = @doc.fetch("schemes", [])[0]
          host   = @doc["host"]
          # TODO: join the basePath also
          (schema && host)? [schema, host].join("://") : ""
        end


        JSON_SCHEMA = {'$ref' => 'http://swagger.io/v2/schema.json#'}.freeze

        def validate!
          JSON::Validator.fully_validate(JSON_SCHEMA, @doc).each do |error|
            @errors.add(:base, error)
          end
        end

        def swagger?
          true
        end

      end


      class V12 < VBase

        JSON_SCHEMA = {'$ref' => 'http://swagger-api.github.io/schemas/v1.2/apiDeclaration.json#'}.freeze

        def validate!
          JSON::Validator.fully_validate(JSON_SCHEMA, @doc).each do |error|
            @errors.add(:base, error)
          end
        end

        def swagger?
          true
        end
      end


      class V10 < VBase
        # This validates an activedocs specification
        # Things *not* handled by this validation
        #  - paramType=body on GET methods
        #  - invalid paramType
        #  - ∞ other things that could go wrong ™
        def validate!
          apis = @doc.fetch('apis', nil)
          unless apis.is_a?(Array)
            @errors.add(:base, :invalid_swagger)
            return
          end

          ops = apis.map{|e| e.nil? ? nil : e["operations"]}.flatten.compact
          ops.each do | operation |
            if operation["parameters"]
              paramTypes = operation["parameters"].map{|e| e["paramType"]}.compact
              if paramTypes.include?("query") && paramTypes.include?("body")
                @errors.add(:base, :invalid_json_body_and_query_paramtypes)
                return # no need to continue to loop
              end
            end
          end
        end

        def swagger?
          false
        end
      end


      extend ActiveModel::Naming
      extend ActiveModel::Translation

      attr_reader :errors, :doc, :version

      # Creates a new specification
      #
      # @param body [String] Le active doc
      def initialize(body)
        @errors = ActiveModel::Errors.new(self)

        begin
          @doc = JSON.parse(body.to_s)
        rescue JSON::ParserError
          @errors.add(:base, :invalid_json)
        end

        @doc = {} unless @doc.is_a?(Hash)

        @version = init_version
      end

      delegate :base_path, :validate!, :swagger?, to: :@version


      # Check if this specification is swagger thus it can be displayed in swagger-ui
      def swagger_1_2?
        @doc.fetch("swaggerVersion", 0).to_f >= 1.2
      end

      def swagger_2_0?
        @doc.fetch("swagger", 0).to_f >= 2.0
      end

      # Falls back to "1.0" if version can"t be determined
      def swagger_version
        if swagger_1_2?
          @doc["swaggerVersion"]
        elsif swagger_2_0?
          @doc["swagger"]
        else
          "1.0"
        end
      end

      def as_json
        doc = Autocomplete.fix!(@doc)
        doc = Schemes.fix!(doc)
        doc
      end

      def valid?
        validate!
        @errors.empty?
      end

      def self.setup_json_validator
        # Disable JSON::Validator access to internet and fs
        JSON::Validator.schema_reader = JSON::Schema::Reader.new(accept_uri: false, accept_file: false)

        # Registers all the schemas in app/lib/three_scale/swagger/schemas
        general = Dir[Rails.root.join("app/lib/three_scale/swagger/schemas/*.schema.json")]
        swagger12 = Dir[Rails.root.join("app/lib/three_scale/swagger/schemas/1.2/*.json")]
        (general + swagger12).each do | file |
          begin
            schema = JSON.parse(File.read(file))
            JSON::Validator.add_schema(JSON::Schema.new(schema, schema["id"]))
          rescue StandardError => error
            Rails.logger.info("** Failed to register schema: #{file} -- #{error}")
          end
        end
      end

      private

      def init_version
        case swagger_version
        when '2.0'
            V20.new(self)
        when '1.2'
            V12.new(self)
        when '1.0'
            V10.new(self)
        else
            VInvalid.new(self)
        end
      end
    end
  end
end

ThreeScale::Swagger::Specification.setup_json_validator
