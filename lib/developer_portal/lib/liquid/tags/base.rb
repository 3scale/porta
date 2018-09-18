module Liquid
  module Tags
    class Base < Liquid::Tag

      extend Liquid::Docs::DSL::Tags

      protected

      # http://robots.thoughtbot.com/post/159806314/custom-tags-in-liquid
      def render_erb(context, file_name, locals={})
        Rails.logger.debug "[LiquidTags]-- rendering #{file_name}: (#{locals.inspect})"
        render_rails(context, :partial => file_name, :formats => [:html], :locals => locals)
      end

      def render_inline(context, template, locals={})
        Rails.logger.debug "[LiquidTags]-- rendering inline template: (#{locals.inspect})"
        render_rails(context, :inline => template, :locals => locals)
      end

      def surround_by_comments(ctx, type, name, content)
        if draft?(ctx) && page(ctx) && page(ctx).content_type == 'text/html'
          name = "'#{name}'" if name
      %{
<!-- BEGIN #{type} #{name} -->
#{content}
<!-- END #{type} #{name} -->
         }
        else
          content
        end
      end

      # beware, Tag's main method is called render
      def render_rails(context, *args)
        case
        when view = context.registers[:view]
          view.send(:render, *args)

        when controller = context.registers[:controller]
          controller.send(:render_to_string, *args)
        else
          raise 'Failed to render a Rails view because neither view nor controller is set'
        end
      end

      def page(context)
        context.registers[:page]
      end

      def draft?(context)
        context.registers[:draft_mode]
      end

      def renderer(context)
        context.registers[:renderer]
      end

      def controller(context)
        context.registers[:controller]
      end

    end
  end
end
