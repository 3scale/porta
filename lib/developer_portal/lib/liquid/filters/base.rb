module Liquid
  module Filters
    module Base
      extend ActiveSupport::Concern

      included do
        extend Liquid::Docs::DSL::Filters
      end

      module ClassMethods
        def doc_title
          self.name
        end

        def register(template = ::Liquid::Template)
          Liquid::Filters.register(self, template)
        end
      end

    end
  end
end
