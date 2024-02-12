module Liquid
  module Tags

    class Submenu < Liquid::Tags::Base
      deprecated "This tag is deprecated, use a 'submenu' partial instead"
      example "Using submenu tag in liquid", %{
        <html>
          <body>
           {% submenu %}
          </body>
        </html>
      }

      desc "Renders a submenu HTML snippet for a logged in user."
      def render(context)
        if context.registers[:controller].send(:logged_in?)
          render_erb context, "shared/buyer_submenu"
        end
      end

    end

  end
end
