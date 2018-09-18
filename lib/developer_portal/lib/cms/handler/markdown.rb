require 'redcarpet'

module CMS
  class Handler
    class Markdown < Base
      RENDERER = Redcarpet::Markdown.new Redcarpet::Render::HTML,
                                         autolink: true,
                                         space_after_headers: true,
                                         fenced_code_blocks: true,
                                         prettify: true
      def convert(markup)
        RENDERER.render(markup.to_s)
      end
    end
  end
end
