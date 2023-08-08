# frozen_string_literal: true

module ThreeScale
  class FilterArguments
    FILTER = ActiveSupport::ParameterFilter.new(Rails.configuration.filter_parameters)

    def initialize(arguments = [])
      @arguments = arguments.dup
    end

    def filter
      return FILTER.filter(@arguments) if parameters_arguments?

      @arguments.map do |argument|
        case argument
        when Struct
          FILTER.filter(argument.to_h)
        when Enumerable
          FILTER.filter(argument)
        else
          argument
        end
      end
    end

    def parameters_arguments?
      case @arguments
      when ActionController::Parameters, Hash
        true
      else
        false
      end
    end
  end
end
