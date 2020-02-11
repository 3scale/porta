# frozen_string_literal: true

module ActiveModel
  module Type
    class StringNotNil < ActiveModel::Type::String
      def cast(value)
        return '' if value.blank?
        super
      end
    end
  end
end
