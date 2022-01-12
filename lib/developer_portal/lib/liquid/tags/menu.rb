# frozen_string_literal: true

module Liquid
  module Tags
    class Menu < Liquid::Tags::Base
      deprecated %(This tag is deprecated, use '{% include "menu" %}' instead.)
      def render(context)
        tag = Liquid::Include.parse('include', '"menu"', '', ParseContext.new)
        tag.render(context)
      end
    end
  end
end
