module Liquid
  module Drops
    class LineItem < Drops::Model

      allowed_name :line_item, :line_items

      example %{
        {% for line_item in invoice.line_items %}
          <tr class="line_item {% cycle 'odd', 'even' %}">
            <th>{{ line_item.name }}</th>
            <td>{{ line_item.description }}</td>
            <td>{{ line_item.quantity }}</td>
            <td>{{ line_item.cost }}</td>
          </tr>
        {% endfor %}
      }

      privately_include do
        include  ActionView::Helpers::NumberHelper
      end

      def initialize(line_item)
        @line_item = line_item
        super
      end

      def name
        @line_item.name
      end

      def description
        @line_item.description
      end

      def quantity
        @line_item.quantity
      end

      def cost
        number_to_currency(@line_item.cost.amount, unit: '')
      end

    end
  end
end
