module Liquid
  module Drops
    class Error < Drops::Base
      info %q{
        When a form fails to submit because of invalid data, the `errors` array
        will be available on the related model.
      }

      example %{
        {% form 'application.update', app %}
          {{ app.errors.first.message }}
           <!-- => description of the first invalid field -->
        {% endform %}
      }

      def initialize(drop, errors, attribute, message)
        @drop = drop
        @errors = errors
        @attribute = attribute
        @message = message
      end

      desc "Returns value of the attribute to which this `error` is related."
      example %q{
        {{ account.errors.org_name.first.attribute }}
        <!-- org_name -->
      }
      def attribute
        @attribute.to_s
      end

      desc "Returns description of the error."
      example %q{
        {{ account.errors.first.message }}
        <!-- can't be blank -->
      }
      def message
        @message.to_s
      end

      desc "Returns value of the attribute to which this `error` is related."
      example %q{
        {{ account.errors.org_name.first.value }}
         <!-- => "ACME Co." -->
      }
      def value
        @drop[attribute]
      end

      desc "Returns full description of the error (includes the attribute name)."
      example %q{
        {{ model.errors.first }}
        <!-- => "Attribute can't be blank" -->
      }
      def to_str
        @errors.full_message(@attribute, @message)
      end

    end
  end
end
