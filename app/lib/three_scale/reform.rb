module ThreeScale
  module Reform

    extend ActiveSupport::Concern

    included do
      prepend OverrideMethods
    end

    module OverrideMethods
      def save_model
        ActiveRecord::Base.transaction do
          super
        end
      end
    end

    def save!(*)
      super
    ensure
      merge_errors
    end

    protected

    def merge_errors
      definitions = property_definitions.values
      definitions.each do |definition|
        model = (on = definition[:on]) ? mapper[on] : self.model
        model.errors[definition[:private_name]].each do |error|
          self.errors.add(definition.name, error)
        end
      end
    end

    def property_definitions
      self.class.representer_class.representable_attrs[:definitions]
    end

    module ClassMethods
      def content_columns
        schema.representable_attrs
      end

      def model_name
        name = self.name.match(/(\w+)Form$/)[1]
        ::ActiveModel::Name.new(self, nil, name)
      end
    end
  end
end
