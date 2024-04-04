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
      schema.each do |value|
        definition = value.instance_values['options']
        model = (on = definition[:on]) ? mapper[on] : self.model
        model.errors[definition[:private_name]].each do |error|
          errors.add(definition[:name].to_sym, error)
        end
      end
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
