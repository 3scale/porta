module Liquid
  module Tags

    class CSRF < Liquid::Tags::Base
      example "Using csrf tag in liquid", %{
        <html>
          <head>
            {% csrf %}
          </head>
        </html>
      }

      desc "Renders the cross site request forgery meta tags."
      def render(context)
        controller = context.registers[:controller].dup
        controller.extend(ActionView::Helpers::TagHelper)
        controller.extend(ActionView::Helpers::CsrfHelper)
        controller.csrf_meta_tag
      end
    end
  end
end
