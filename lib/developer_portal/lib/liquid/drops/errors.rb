module Liquid
  module Drops
    class Errors < Drops::Base

      drop_example 'Get errors of one attribute.', '''
        {% for error in form.errors.description %}
          attribute: {{ error.attribute }}
          message: {{ error.message }}
          full message: {{ error }}
        {% endfor %}
      '''
      drop_example 'Get all errors.', '''
        {% for error in form.errors %}
          attribute: {{ error.attribute }}
          ...
        {% endfor %}
      '''
      def initialize(model)
        @model = model
        @errors = model.errors
      end

      desc "Returns true if there are no errors."
      example %{
        {% if form.errors == empty %}
          Contgratulations! You have no errors!
        {% endfor %}
      }
      def empty?
        @errors.try(:empty?)
      end

      desc "Returns true if there are errors."
      example '''
        {% if form.errors == present %}
          Sorry, there were errors.
        {% endfor %}
      '''
      def present?
        not empty?
      end

      hidden

      def each
        return enum_for unless block_given?

        @errors.each do |attribute, message|
          yield field(attribute, message)
        end
      end

      hidden

      def to_ary
        each.to_a
      end

      hidden

      def before_method(attribute)
        name = attribute.to_s
        errors = @errors[name]
        errors.map{ |message| field(name, message) }
      end

      private

      def field(attribute, message)
        Errors::Message.new(@errors, attribute, message)
      end

      class Message < Drops::Base
        def initialize(errors, attribute, message)
          @errors = errors
          @attribute = attribute
          @message = message
        end

        def attribute
          @attribute.to_s
        end

        def message
          @message.to_s
        end

        def to_str
          @errors.full_message(@attribute, @message)
        end
      end

    end
  end
end
