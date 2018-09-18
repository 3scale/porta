module Liquid
  module Drops
    class Fields < Drops::Base
      def initialize(object, fields)
        @object = object
        @fields = fields
      end

      # All fields
      def self.fields(object)
        new(object, object.defined_fields)
      end

      def self.builtin_fields(object)
        fields = object.defined_fields.select do |f|
          object.builtin_field?(f.name)
        end

        new(object, fields)
      end

      def self.extra_fields(object)
        fields = object.defined_fields.select do |f|
          object.extra_field?(f.name)
        end

        new(object, fields)
      end

      delegate :each, :first, :last, :empty?, :present?, to: :drops

      protected

      def drops
        @drops ||= @fields.map do |field|
          if @object.builtin_field?(field.name) && field.name.to_s == 'country'
            Drops::CountryField.new(@object, field.name)
          else
            Drops::Field.new(@object, field.name)
          end
        end
      end

      # Like method missing; not called before a defined method.
      def before_method(name)
        drops.find {|drop| drop.name == name }
      end

    end
  end
end
