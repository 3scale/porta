# frozen_string_literal: true
module Symbolize


  extend ActiveSupport::Concern

  included do
    prepend AttributesAccessor
    class_attribute :__symbolized_attributes, instance_writer: false
  end

  module AttributesAccessor
    def attribute_previous_change(attr)
      __symbolize_changes(attr, super)
    end

    def attribute_change(attr)
      __symbolize_changes(attr, super)
    end

    private
    def __symbolize_changes(attr, changed_values)
      if changed_values.blank? || __symbolized_attributes.exclude?(attr.to_sym)
        changed_values
      else
        changed_values.map{|value| value.blank? ? value : value.to_sym }
      end
    end
  end

  module ClassMethods
    def symbolize(*attributes)
      self.__symbolized_attributes ||= []
      attributes.each do |attr|
        unless self.__symbolized_attributes.include?(attr.to_sym)
          define_symbolized_attribute_method(attr)
          self.__symbolized_attributes += [attr.to_sym]
        end
      end
    end

    def define_symbolized_attribute_method(attr)
      define_method(attr) do
        value = super()
        return if value.blank?
        return value if __symbolized_attributes.exclude?(attr.to_sym)
        value.to_sym
      end
    end
  end
end
