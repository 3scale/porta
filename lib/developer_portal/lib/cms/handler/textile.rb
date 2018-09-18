require 'redcloth'

module CMS
  class Handler
    class Textile < Base
      def convert(markup)
        RedCloth.new(markup).to_html
      end
    end
  end
end
