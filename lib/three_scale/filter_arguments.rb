# frozen_string_literal: true

module ThreeScale
  # This class is used to filter sensitive parameters from hashes inside an array of
  # arguments. It depends on ActionDispatch::Http::ParameterFilter.
  #
  # ActionDispatch::Http::ParameterFilter will be removed in Rails 6.1. After we need to change to
  # ActiveSupport::ParameterFilter
  class FilterArguments
    FILTER = ActionDispatch::Http::ParameterFilter.new(Rails.configuration.filter_parameters)

    def initialize(arguments = [])
      @arguments = arguments.dup
    end

    def filter
      return FILTER.filter(@arguments) if @arguments.is_a?(Hash)

      @arguments.map { |argument| argument.is_a?(Enumerable) ? FILTER.filter(argument) : argument }
    end
  end
end
