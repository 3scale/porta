module Liquid
  module Forms
    class Base
      attr_reader :context

      #include Rails.application.routes.url_helpers
      include DeveloperPortal::Engine.routes.url_helpers

      delegate :tag, :content_tag, to: 'Liquid::Filters::RailsHelpers'

      DEFAULT_CLASS = 'formtastic'

      attr_reader :object_name

      def initialize(context, object_name, html_attributes= {})
        @context = context
        @object_name = object_name
        @html_attributes = html_attributes
      end

      def form_method
        :post
      end

      def controller
        @context.registers.fetch(:controller)
      end

      def object
        unless @object_name.present?
          raise MissingObjectError, "no object specified (correct syntax: {% form 'name', object %})"
        end

        unless object = @context[@object_name]
          raise MissingObjectError, "variable '#{@object_name}' is missing"
        end

        object
      end

      def object_param_name(model)
        model.class.model_name.param_key
      end

      def metadata
        csrf_name = controller.request_forgery_protection_token.to_s
        csrf_value = controller.send(:form_authenticity_token)

        token_tag = tag(:input, type: "hidden", name: csrf_name, value: csrf_value)
        utf8_tag = tag(:input, type: "hidden", name: "utf8", value: "&#x2713;".html_safe)
        method_tag = tag(:input, type: "hidden", name: "_method", value: http_method.to_s)

        content_tag(:div, utf8_tag + token_tag + method_tag, style: "margin:0;padding:0;display:inline")
      end

      def render(content)
        content_tag(:form, metadata + content, form_options.stringify_keys.update(@html_attributes.except("class")))
      end

      def html_class_names
        [ DEFAULT_CLASS, html_class_name, @html_attributes["class"] ].compact
      end

      # to override
      def html_class_name
      end

      def form_options
        {
          'action' => path,
          'method' => form_method,
          'class'  => html_class_names.join(' '),
          'accept-charset' => 'UTF-8'
        }
      end

    end
  end
end
