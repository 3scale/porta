module Liquid
  module Tags

    class Footer < Liquid::Tags::Base

      desc "Renders a footer HTML snippet."
      deprecated "This tag is deprecated, use a CMS partial instead"
      def render(context)
        # it used to be: if context.registers[:site_account].config[:advanced_cms]
        Liquid::Template.parse('{% include "footer" %}').render(context)
      end
    end
  end
end
