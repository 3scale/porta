require 'liquid'

module CMS
  class Renderer

    attr_reader :page, :layout

    def initialize(page, options = {}, &block)
      @page, @options = page, options
      @block = block
    end

    # TODO: cache results

    def content
      page = render(@page)

      if layout = @page.layout
        render(layout, :content => page)
      else
        page
      end
    end

    def render(template, assigns = {}, options = {})
      options[:registers] = default_registers.merge(options[:registers] || {}).symbolize_keys
      assigns = default_assigns.merge(assigns.stringify_keys)

      args = assigns, options

      template = parse(template)

      if raise_exceptions?
        template.render!(*args)
      else
        template.render(*args)
      end
    end

    def parse(record)
      content = record.content(draft?)

      template = if record.liquid_enabled?
                   Liquid::Template.parse(content)
                 else
                   Solid::Template.parse(content, record.is_a?(CMS::Layout))
                 end

      @block.call(template) if @block

      CMS::Handler.new(record.handler).renders(template)
    end

    private

    def default_assigns
      @options.fetch(:assigns, {})
    end

    def default_registers
      { :page => @page, :renderer => self, :draft_mode => draft? }
    end

    def raise_exceptions?
      Rails.env.development? or Rails.env.test?
    end

    def draft?
      @options[:draft].present?
    end


    ## Solid
    #
    # Mimics Liquid template,
    # but only tag which can be used is {% content %}
    # to display page in layout
    #
    # Output can be cached
    #

    module Solid
      class Template
        CONTENT_TAG = /(\{%\s*content\s*%\})/

        def self.parse(content, act_as_layout)
          new(content, act_as_layout)
        end

        attr_reader :registers, :assigns

        def initialize(content, act_as_layout)
          @content = content
          @act_as_layout = act_as_layout
          @registers = {}
          @assigns = {}
        end

        def render(assigns = {}, options = {})
          @registers = registers.merge(options.fetch(:registers, {}))
          @assigns = self.assigns.merge(assigns)

          if @act_as_layout && @content =~ CONTENT_TAG
            @content.gsub(CONTENT_TAG, assigns.fetch('content'))
          else
            @content
          end
        end

        alias render! render

      end
    end
  end
end
