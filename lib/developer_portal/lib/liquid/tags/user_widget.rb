module Liquid
  module Tags
    class UserWidget < Liquid::Tags::Base
      example "Using user_widget tag in liquid", %{
        <html>
          <body>
           {% user_widget %}
            <p class="notice">If you are logged in you see profile related links above.</p>
            <p class="notice">If you are not login you are invited to login or signup.</p>
          </body>
        </html>
      }

      desc "Renders a user widget HTML snippet."
      deprecated "This tag is deprecated, use a CMS partial instead"
      def render(context)
        render_erb context, 'shared/user_widget'
      end
    end
  end
end
