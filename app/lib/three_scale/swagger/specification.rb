module ThreeScale
  module Swagger
    class Specification
      class VBase
        def initialize(spec)
          @doc = spec.doc
          @errors = spec.errors
          @validator = JSONValidator.new(@doc)
        end

        # The base path of the specification. This is needed to have it whitelisted on api_docs_proxy.
        def base_path
          @doc.fetch("basePath", nil).try(:downcase)
        end

        def servers
          [base_path]
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

      class V30 < VBase
        def base_path
          servers.first
        end

        JSON_SCHEMA = {'$ref' => 'https://spec.openapis.org/oas/3.0/schema/2019-04-02'}.freeze

        def validate!
          @validator.fully_validate(JSON_SCHEMA).each do |error|
            @errors.add(:base, error)
          end
        end

        def swagger?
          true # FIXME: Is it really!?
        end

        def servers
          @servers ||= ThreeScale::OpenApi::UrlResolver.new(@doc).servers
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
          @validator.fully_validate(JSON_SCHEMA).each do |error|
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
          @validator.fully_validate(JSON_SCHEMA).each do |error|
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
          return if @errors.include? :base

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

      delegate :base_path, :servers, :validate!, :swagger?, to: :@version

      # Check if this specification is swagger thus it can be displayed in swagger-ui
      def swagger_1_2?
        doc_version.to_f >= 1.2
      end

      alias swagger_1_2_or_newer? swagger_1_2?

      def swagger_2_0?
        doc_version.to_f >= 2.0
      end

      def openapi_3_0?
        doc_version.to_f >= 3.0
      end

      # Falls back to "1.0" if version can"t be determined
      def swagger_version
        swagger_1_2_or_newer? ? doc_version.scan(/\A(\d+\.\d+)(\..+)?\Z/).flatten.first : '1.0'
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

      protected

      def version_attribute
        %w[openapi swagger swaggerVersion].find(&@doc.method(:has_key?))
      end

      def doc_version
        @doc[version_attribute]
      end

      private

      def spec_version_class
        "ThreeScale::Swagger::Specification::V#{swagger_version.sub(/\./, '')}".constantize
      rescue NameError
        VInvalid
      end

      def init_version
        spec_version_class.new(self)
      end
    end
  end
end
