module ThreeScale

  module Swagger

    # This transforms an ActiveDoc Spec into a Swagger 1.2 Spec so it can be viewed in swagger-ui
    #
    # Note: By default we treat all documents with a swaggerVersion as being
    # swagger 1.2 spec compliant thus by passing all the transformations
    class Translator

      # Constructor that applies all the available translations, each modifying the active doc.
      #
      # Avaliable Translations:
      #
      #   * method - replaces httpMethod with method
      #   * version - added swaggerVersion attribute with value 1.2
      #   * nickname - required by swagger-ui for each operation to have a nickname
      #
      # Special key __notification is added to the transformed document
      # and will contain a list of generated warnings.
      #
      # @param active_doc [String] The active doc to translate
      # @param stages [Array] List of transformations to apply
      # @return [ThreeScale::Swagger::Translator]
      def self.translate!(active_doc, stages = [:method, :version, :nickname])
        translator = self.new(active_doc)
        stages.map{|t| translator.send("#{t}_translator".to_sym)}
        translator
      end


      # @return [Hash] The active doc as JSON parsed document
      def swagger(options={})
        unless @swagger
          @swagger = Autocomplete.fix!(::JSON.parse(@active_doc, options))
          @swagger = Schemes.fix!(@swagger)
        end
        @swagger
      end

      alias as_json swagger

      protected

      def initialize(active_doc)
        @active_doc = active_doc
        swagger["__notifications"] = []
      end

      def operations
        @_ops ||= swagger.fetch('apis',[]).flat_map{ |w| w['operations'] }.compact
      end

      # 1. replace httpMethod with method
      def method_translator
        operations.each do | op |
          if op['method'].blank? && op['httpMethod']
            op['method']= op.delete('httpMethod')
            swagger["__notifications"] << "001: replace `httpMethod' with `method'"
          end
        end
      end

      # 2. adds a swagger version
      def version_translator
        unless swagger['swaggerVersion']
          swagger['swaggerVersion'] = "1.2"
          swagger["__notifications"] << "002: missing `swaggerVersion'"
        end
      end

      # 3. each operation should have a nickname
      # TODO: maybe pick something like (apis.path + operation.method).downcase.gsub(/{}\//, '_')
      #   but this means to keep a back reference to each operation path
      def nickname_translator
        operations.each do | op |
          if op['nickname'].blank?
            op['nickname']= Time.zone.now.to_i.to_s
            swagger["__notifications"] << "003: missing mandatory `nickname'. a random one was generated."
          end
        end
      end
    end
  end
end

