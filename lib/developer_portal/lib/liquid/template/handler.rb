module Liquid
  class Template
    class Handler
      def self.call(template)
        "Liquid::Template::Handler.new(self).render(#{template.source.inspect}, local_assigns)"
      end

      def initialize(view)
        @view = view
      end

      def render(template, local_assigns = {})
        @view.controller.headers["Content-Type"] ||= 'text/html; charset=utf-8'

        controller = @view.controller
        assigns = controller.assigns_for_liquify

        if @view.content_for?(:layout)
          assigns['content'] = @view.content_for(:layout)
        end

        template = Liquid::Template.parse(template)
        controller.send(:prepare_liquid_template, template)

        template.registers[:view] ||= @view

        template.render!(assigns, local_assigns)
      end

      def compilable?
        false
      end
    end
  end
end
