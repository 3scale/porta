module Liquid
  module Tags
    class EssentialAssets < Liquid::Tags::Base
      include Liquid::Tags::ContentFor::ContentFor
      nodoc!

      # this makes versioning harder, delete it

      def render(context)
        [
            stylesheets.render(context),
            render_erb(context, "shared/essential_assets"),
            javascripts.render(context)
        ].join.html_safe
      end
    end
  end
end
