module Liquid
  module Drops
    class Field < Drops::Base
      EMPTY_VALUE = ''

      def initialize(object, name)
        @object, @name = object, name
        @field = @object.field(name)
      end

      desc "Returns value of the field."
      example %{
        Name: {{ account.fields.first_name.value }}
      }
      def value
        val = @object.field_value(name) || EMPTY_VALUE
        val && val.respond_to?(:to_liquid) ? val : val.to_s
      end

      desc "Returns system name of the field."
      def name
        @field.name.to_s
      end

      def required
        @field.required
      end

      def hidden?
        @field.hidden
      end

      alias hidden hidden?

      def visible?
        !@field.hidden
      end

      alias visible visible?

      def read_only
        @field.read_only
      end

      def errors
        Drops::Errors.new(@object)[@field.name]
      end

      desc "Returns the name for the HTML input that is expected when the form is submitted."
      example %{
        <input name="{{ account.fields.country.input_name }}" value="{{account.fields.country}}" />
        <!-- the 'name' attribute will be 'account[country]' -->
      }
      def input_name
        "#{object_name}[#{name}]"
      end

      desc "Returns a unique field identifier that is commonly used as HTML ID attribute."
      example %{
        {{ account.fields.country.html_id }}
        <!--  => 'account_country' -->
      }
      def html_id
        # we replace all brackets by underscores and cut the last one
        self.input_name.tr_s("[]", "_")[0..-2]
      end

      desc "Returns label of the field."
      example %{
        {{ account.fields.country.label }}
        <!-- => 'Country' -->
      }
      def label
        @field.label
      end

      desc "Returns the value of the field if used as variable."
      example %{
        {{ account.fields.first_name }} => 'Tom'
      }
      def to_str
        value.to_s
      end

      class Choice < Drops::Base
        def initialize(label, id = nil)
          @label, @id = label, id
        end

        def label
          @label
        end

        def id
          @id ? @id : @label
        end

        alias to_str label
        alias to_s to_str
      end

      desc %{
             Returns array of choices available for that field, if any. For example,
             for a field called `fruit` it may respond with `['apple', 'bannana', 'orange']`.

             You can define the choices in your [admin dashboard][fields-definitions].
             Each of the array elements responds to `id` and `label` which
             are usually just the same unless the field is a special built-in one (like `country`)
             It is recommended to use those methods rather that output the `choice` 'as is'
             for future compatibility.
            }
      example %{
        {% for choice in field.choices %}
          <select name="{{ field.input_name }}" id="{{ field.html_id }}_id"
                  class="{{ field.errors | error_class }}">
          <option {% if field.value == choice %} selected {% endif %} value="{{ choice.id }}">
            {{ choice }}
          </option>
        {% endfor %}
      }
      def choices
        @choices ||= @field.choices.map { |c| Choice.new(c) }
      end

      def ==(other)
        to_str == other or super
      end

      protected

      # name like for the input eg: cinstance[attribute]
      def object_name
        @object_name ||= if form = @context.registers[:form]
                           form.object_param_name(@object)
                         else
                           @object.class.model_name.param_key
                         end
      end

    end
  end
end
