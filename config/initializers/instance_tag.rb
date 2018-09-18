module ActionView
  module Helpers
    class InstanceTag
      class << self
        # Because of old formatastic
        def check_box_checked?(value, checked_value)
          case value
          when TrueClass, FalseClass
            value
          when NilClass
            false
          when Integer
            value != 0
          when String
            value == checked_value
          when Array
            value.include?(checked_value)
          else
            value.to_i != 0
          end
        end
      end
    end
  end
end
