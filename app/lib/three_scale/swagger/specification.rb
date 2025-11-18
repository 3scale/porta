# frozen_string_literal: true

module ThreeScale
  module Swagger
    class Specification
      class VBase
        attr_reader :doc, :errors

        def initialize(spec)
          @doc = spec.doc
          @errors = spec.errors
        end

        # The base path of the specification. This is needed to have it whitelisted on api_docs_proxy.
        def base_path
          doc.fetch("basePath", nil).try(:downcase)
        end

        def servers
          [base_path]
        end

        def validate
          raise "#{self.class} should implement #{__method__}"
        end

        def swagger?
          raise "#{self.class} should implement #{__method__}"
        end

        def as_json
          Schemes.fix!(Autocomplete.fix!(doc))
        end
      end

      class VInvalid < VBase
        def validate
          errors.add(:base, :invalid_version)
        end

        def swagger?
          false
        end
      end

      class V3x < VBase
        def base_path
          servers.first
        end

        def validate
          JSONSchemer.openapi(doc).validate.to_a.map { _1.fetch('error') }.each do |error|
            errors.add(:base, error)
          end
        end

        # NOTE: it's technically OpenAPI, and not Swagger,
        # but it is rendered by swagger-ui
        def swagger?
          true
        end

        def servers
          @servers ||= ThreeScale::OpenApi::UrlResolver.new(doc).servers
        end

        def as_json
          Autocomplete.fix!(doc)
        end
      end

      class V31 < V3x; end

      class V30 < V3x; end

      class Swagger < VBase
        def self.json_schema_path
          raise "#{self} should implement #{__method__}"
        end

        def self.json_schema
          @json_schema ||= JSON.parse(Rails.root.join(json_schema_path).read).freeze
        end

        DRAFT4_RESOLVER = {
          JSONSchemer::Draft4::BASE_URI.dup.tap { |uri| uri.fragment = nil } => JSONSchemer::Draft4::SCHEMA
        }.to_proc

        def validate
          JSONSchemer.schema(self.class.json_schema, ref_resolver: DRAFT4_RESOLVER).validate(doc).to_a.map { _1.fetch('error') }.each do |error|
            errors.add(:base, error)
          end
        end

        def swagger?
          true
        end
      end

      class V20 < Swagger
        # NOTE:
        #   * "If the schemes is not included, the default scheme to be used is the one used to access the specification."
        #   * "If the host is not included, the host serving the documentation is to be used (including the port)."
        # To accomplish this we return an empty string.
        # ApiDocsProxy supports only http/s
        def base_path
          schema = doc.fetch("schemes", [])[0]
          host   = doc["host"]
          # TODO: join the basePath also
          (schema && host)? [schema, host].join("://") : ""
        end

        def self.json_schema_path
          'app/lib/three_scale/swagger/schemas/swagger-2.0.schema.json'
        end
      end

      class V12 < Swagger
        def self.json_schema_path
          'app/lib/three_scale/swagger/schemas/swagger-1.2.schema.json'
        end
      end

      class V10 < VBase
        # This validates an activedocs specification
        # Things *not* handled by this validation
        #  - paramType=body on GET methods
        #  - invalid paramType
        #  - ∞ other things that could go wrong ™
        def validate
          return if errors.added? :base, :invalid_json

          apis = doc.fetch('apis', nil)
          unless apis.is_a?(Array)
            errors.add(:base, :invalid_swagger)
            return
          end

          ops = apis.map{|e| e.nil? ? nil : e["operations"]}.flatten.compact
          ops.each do | operation |
            if operation["parameters"]
              paramTypes = operation["parameters"].map{|e| e["paramType"]}.compact
              if paramTypes.include?("query") && paramTypes.include?("body")
                errors.add(:base, :invalid_json_body_and_query_paramtypes)
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

      delegate :base_path, :servers, :validate, :swagger?, :as_json, to: :@version

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

      def valid?
        validate
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
