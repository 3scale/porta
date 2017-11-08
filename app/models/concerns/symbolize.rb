# frozen_string_literal: true
module Symbolize
  def symbolize(*attributes)
    attributes.each do |attr|
      class_eval <<-DEFINITION
      def #{attr}
        value = super
        return if value.blank?
        value.to_s.to_sym
      end
      DEFINITION
    end
  end
end
