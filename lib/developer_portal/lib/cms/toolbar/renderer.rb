# frozen_string_literal: true

module CMS::Toolbar
  class Renderer
    attr_reader :page
    attr_writer :layout

    def initialize
      @templates = []
      @liquids = []
    end

    def liquid(template)
      @liquids << template
    end

    def rendered(view)
      @templates << view
    end

    def main_page=(page)
      if @page
        rendered(page)
      else
        @page = page
      end
    end

    def layout
      @layout or @page.try(:layout)
    end

    def assigns
      liquids = @liquids.try(:map){ |t| t.registers[:file_system].try(:history) } || []
      templates = [ page, layout ] + liquids + @templates

      { page: page, templates: templates.flatten.compact.uniq }
    end
  end
end
