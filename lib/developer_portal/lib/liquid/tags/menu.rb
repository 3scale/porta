module Liquid
  module Tags
    class Menu < Liquid::Tags::Base
      deprecated %(This tag is deprecated, use '{% include "menu" %}' instead.)
      def render(context)
        template = Liquid::Template.parse('{% include "menu" %}')
        template.render(context)
      end
    end
  end
end
