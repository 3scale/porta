module Liquid
  module Tags
    class Debug < Base
      include ActionView::Helpers::ApplicationHelper
      # vars excluded from the help message
      PROTECTED_ASSIGNS = %w{ content_for_layout }

      info %{
        Prints all liquid variables available in a template into an HTML comment.'
        We recommend __to remove this tag__ from public templates.
      }

      example %{
        {% debug:help %}
      }

      def initialize(tag_name, markup, tokens)
        @mode = markup[1..-1].strip.presence # without first char
        super
      end

      def render(context)
        if @mode == 'help'
          render_help(context)
        end
      end

      def render_help(context)
        output = ["  Liquid Debug Help", nil]

        output << "    You can use following variables:"
        output << "    ================================"

        output.concat help(assigns(context))

        output << "    ================================"
        output << "    Check more info at #{::I18n.t 'docs.developer_portal.liquid_reference', docs_base_url: docs_base_url, docs_anchor: docs_anchor}"

        html_comment(output)
      end

      def help(assigns)
        assigns = Hash[
          assigns.map do |name, value|
            klass = value.class
            klass_name = if klass.respond_to?(:name)
                           klass.name
                         else
                           klass.to_s
                         end

            [ name, { value: value, label: klass_name.split('::').last }]
          end
        ]

        max = {
          :name => assigns.keys.map(&:length).max,
          :label => assigns.values.map{|value| value[:label].length }.max
        }

        assigns.map do |name, value|
          next if PROTECTED_ASSIGNS.include?(name)

          line = "    #{name.ljust(max[:name])} => "
          line << value[:label].ljust(max[:label])

          line
        end.compact
      end

      def assigns(context)
        assigns = {}

        context.environments.each do |env|
          env.each do |name, value|
            klass = value.class
            next if klass.respond_to?(:nodoc?) && klass.nodoc?
            assigns[name] = value
          end
        end

        assigns
      end

      def html_comment(*texts)
        %{\n<!--\n#{texts.join("\n")}\n-->\n}
      end
    end
  end
end
