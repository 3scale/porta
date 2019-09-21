# frozen_string_literal: true

module ActiveRecord
  module Type
    class StringNotNil < ActiveRecord::Type::String
      def type_cast(value)
        return '' if value.blank?
        super
      end
    end
  end
end
