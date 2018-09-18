module CMS
  class Handler

    def self.available
      [:markdown, :textile]
    end

    def initialize(handler)
      @handler = handler
    end

    def renders(template)
      case @handler

      when :markdown
        CMS::Handler::Markdown.new(template)

      when :textile
        CMS::Handler::Textile.new(template)

      else
        CMS::Handler::Nothing.new(template)

      end
    end

  end
end
