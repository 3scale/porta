module Liquid
  module Drops
    class CountryField < Field

      def html_id
        "#{object_name}_country"
      end

      def choices
        @choices = ::Country.all.map { |c| Choice.new(c.name, c.id) }
      end

      desc "Returns name of the country."
      example %{
        {{ account.fields.country }} => 'United States'
      }
      def to_str
        @object.field_value(name) || EMPTY_VALUE
      end

      def input_name
        "#{object_name}[country_id]"
      end

      desc "Returns ID of the country."
      example %{
        {{ account.fields.country.value }} => 42

        compare with:

        {{ account.fields.country }} => 'United States'
      }
      def value
        @object.country.try(:id)
      end
    end
  end
end
