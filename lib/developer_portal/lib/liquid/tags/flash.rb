module Liquid
  module Tags

    class Flash < Liquid::Tags::Base
      example "Using flash tag in liquid", %{
        <html>
          <body>
           {% flash %}
          </body>
        </html>
      }

      desc "Renders informational or error messages of the system."
      deprecated "This tag is deprecated, use FlashDrop instead."
      def render(context)
        if flash = context.registers[:controller].flash
          render_erb(context, 'shared/flash_message', :flash => flash)
        end
      end

    end
  end
end
