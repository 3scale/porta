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
        controller = context.registers[:controller].dup
        controller.disable_client_cache
        nil
      end
    end
  end
end
