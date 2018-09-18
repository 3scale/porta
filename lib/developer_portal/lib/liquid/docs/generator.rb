module Liquid
  module Docs
    class Generator

      def initialize
        @markdown = ''
      end

      def to_markdown
        @markdown
      end

      def to_html
        require 'html/pipeline'

        pipeline = HTML::Pipeline.new [
                                       HTML::Pipeline::MarkdownFilter,
                                       HTML::Pipeline::TableOfContentsFilter,
                                      ]

        builder = Proc.new do |toc|
          if toc.level == 0
            list_items = toc.map do |t|
              %{<li><a href="##{t.reference}">#{t.title}</a>#{t.to_html}</li>}
            end

            ul = """
          <ul id='#{toc.html_id}' >
            <a name="'#{toc.html_id}'"></a>
            #{list_items.join("\n")}
          </ul>
          """

            root = toc.parent_header.children.first
            root.add_previous_sibling(ul)
            # elsif toc.level < 2
            #   html = toc.to_html("h#{toc.level + 1}-toc")
            #   toc.parent_header.add_next_sibling(html)
          elsif toc.level == 2
            toc.parent_header.add_next_sibling('<span class="up"> <a href="#table-of-contents">(up)</a></span>')
          end
        end

        pipeline.call(@markdown, gfm: false, toc_builder: builder)[:output]
      end

      def <<(doc)
        if doc.respond_to?(:to_markdown)
          @markdown << doc.to_markdown << "\n"
        else
          @markdown << doc
        end
      end
    end
  end
end
