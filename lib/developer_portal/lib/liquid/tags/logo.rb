module Liquid
  module Tags

    class Logo < Liquid::Tags::Base
      example "Using menu tag in liquid", %{
        <html>
          <body>
           {% logo %}
          </body>
        </html>
      }

      desc "Renders the logo."
      deprecated "This tag is deprecated, use {{ provider.logo_url }} instead."
      def render(context)
        render_erb context, 'shared/logo'
      end

    end

  end
end
