module Liquid
  module Tags

    class SortLink < Liquid::Tags::Base
      example "Using sort_link in liquid", %{
        <html>
          <table>
            <thead>
              <tr>
                <th>
                  {% sort_link column: 'level'  %}
                </th>
                <th>
                  {% sort_link column: 'timestamp' label: 'Time'  %}
                </th>
              </tr>
            </thead>
          </table>
        </html>
      }

      SYNTAX = /column:\s?"([\w]+)"(?:\s?label?:\s?"([\w]+)")?/

      def initialize(tag_name, params, tokens)
        if params =~ SYNTAX
          @column = $1
          @label = $2
        else
          raise SyntaxError.new("Syntax Error in 'sort_link' - Valid syntax: sort_link column: [column] label: [label]")
        end

        super
      end

      desc "Renders a link that sorts the column of table based on current params"
      def render(context)
        action_view = context.registers[:controller].view_context
        action_view.sortable(@column, @label) if action_view.respond_to?(:sort_column)
      end
    end
  end
end
