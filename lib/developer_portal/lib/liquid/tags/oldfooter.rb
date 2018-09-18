module Liquid
  module Tags

    class Oldfooter < Liquid::Tags::Base

      desc "Renders a footer HTML snippet."
      deprecated "This tag is deprecated, use a CMS partial instead"
      def render(context)
        render_erb context, 'shared/footer'
      end
    end
  end
end
