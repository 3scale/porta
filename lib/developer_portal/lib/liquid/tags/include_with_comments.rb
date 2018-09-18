# -*- coding: utf-8 -*-
module Liquid
  module Tags
    class IncludeWithComments < Liquid::Include

      extend Liquid::Docs::DSL::Tags

      tag 'include'
      info %{
       Includes a partial specified by name.
       If you are in draft mode and the page has content type 'text/html', the partial
       is surrounded by HTML comments marking the beginning and end of it.
      }

      example "Using include tag in a layout", %{
        <html>
          <body>
           {% include 'sidebar' %}
           {% content %}
          </body>
        </html>
      }

      def name
        'include'
      end

      # TODO: DRY with Liquid::Tags::Base
      #
      def render(context)
        page = context.registers[:page]
        draft = context.registers[:draft_mode]

        if draft && page && page.content_type == 'text/html'
          name = context[@template_name]
        %{
<!-- BEGIN_PARTIAL '#{name}' -->
#{super}
<!-- END_PARTIAL '#{name}' -->
         }
        else
          super
        end
      end

    end
  end
end
