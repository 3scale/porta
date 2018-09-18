module Liquid
  module Tags
    class ThreeScaleEssentials < Liquid::Tags::Base
      include Liquid::Tags::ContentFor::ContentFor

      tag '3scale_essentials'

      def render(context)
        render_inline context, %{
          <%= csrf_meta_tag %>
          #{stylesheets.render(context)}
          <!--[if IE]>
            <%= javascript_include_tag 'vendor/excanvas.compiled.js' %>
          <![endif]-->
          <%= javascript_include_tag '/javascripts/3scale.js' %>
          <%= yield :javascripts %>
          #{javascripts.render(context)}
        }
      end
    end
  end
end
