module Liquid
  module Filters
    module FormHelpers
      include Liquid::Filters::Base
      DEFAULT_ERROR_CLASS = 'error'.freeze
      DEFAULT_INLINE_ERRORS_CLASS = 'inline-errors'.freeze

      example 'Using error_class to show output an error class.', '
        <input class="{{ form.errors.description | error_class }}" />
      '

      desc 'Outputs error class if argument is not empty.'
      def error_class(errors, class_name = DEFAULT_ERROR_CLASS)
        errors.present? ? class_name : ''
      end

      example 'Using inline_errors to show errors inline.', '
        {{ form.errors.description | inline_errors }}
      '
      desc 'Outputs error fields inline in paragraph.'
      # @param [Liquid::Drops::Errors] errors
      def inline_errors(errors, class_name = DEFAULT_INLINE_ERRORS_CLASS)
        return unless errors.present?

        messages = Array(errors).map { |error| error.try(:message) || error.to_s }
        Filters::RailsHelpers.content_tag(:p, messages.to_sentence, class: class_name)
      end
    end
  end
end
