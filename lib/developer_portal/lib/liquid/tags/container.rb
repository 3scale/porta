module Liquid
  module Tags
    class Container < Base
      # Deprecated! Use partials instead.
      #
      nodoc!

      tag 'container'

      example "Using container tag in liquid", %{
        <html>
          <head>
           {% essential_assets %}
          </head>
          <body>
           {% container main %}
           <p class="notice">If a CMS page uses this layout you will have a container at your disposal to add content to.</p>
          </body>
        </html>
      }

      desc "Defines a container in the layout to add content to using the visual editor."
      def initialize(tag_name, markup, tokens)
        @name = markup.strip =~ /\A(#{QuotedString})\Z/ ? $1[1..-2] : markup.strip
        super
      end

      def render(context)
        if partial = find_partial(context)
          liquid_options = { :template => partial }
          content = renderer(context).render( partial, {}, liquid_options)
          surround_by_comments( context, 'PARTIAL', partial.system_name, content)
        end
      end

      private

      def find_partial(context)
        page = page(context)
        if partial_name = page && "#{@name}_#{page.id}"
          if fs = context.registers[:file_system]
            fs.find_partial(partial_name)
          end
        end
      end

    end
  end
end
