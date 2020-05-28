# frozen_string_literal: true

module ThreeScale

  class Deprecation < ActiveSupport::Deprecation # :nodoc:

    def initialize(deprecation_horizon = 'future version', gem_name = '3scale')
      super
    end

    # # WARNING: This is a private method in ActiveSupport::Deprecation
    # # Uncomment this to have custom default deprecation message
    # def deprecation_message(callstack, message = nil)
    #   message ||= 'You are using a deprecated method.'
    #   "DEPRECATION WARNING: #{message} #{deprecation_caller_message(callstack)}"
    # end

    # Deprecator class
    # Custom deprecator to display message warning for deprecation
    class Deprecator
      def deprecation_warning(
        deprecated_method_name, message = nil, caller_backtrace = nil
      )
        caller_backtrace ||= caller_locations(2)
        message ||= "`#{deprecated_method_name}' is not fully implemented."
        ThreeScale::Deprecation.warn(message, caller_backtrace)
      end
    end
  end
end
