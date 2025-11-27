module Liquid
  module Tags

    class DisableClientCache < Liquid::Tags::Base
      example "Disable browser cache for this screen", %{
        <html>
          <head>
            {% disable_client_cache %}
          </head>
        </html>
      }

      desc "Adds HTTP headers to disable the browser cache for the current screen."
      def render(context)
        context.registers[:controller].disable_client_cache
        ''
      end
    end
  end
end
