module Liquid
  class Template
    class Handler
      # DEPRECATION WARNING: Single arity template handlers are deprecated. Template handlers must
      # now accept two parameters, the view object and the source for the view object.
      def self.call(template, source = template.source)
        "Liquid::Template::Handler.new(self).render(#{source.inspect}, local_assigns)"
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
