module Liquid
  module Tags
    class Portlet < Base
      tag 'portlet'

      info %{
        This tag includes portlet by system name.
      }

      def initialize(tag_name, markup, tokens)
        @template_name = markup.strip =~ /\A(#{QuotedString})\Z/ ? $1[1..-2] : markup.strip
        super
      end

      def render(context)
        if portlet = find_portlet(context)
          liquid_options = portlet.liquid_options.merge(:registers => {:template => portlet})
          content = renderer(context).send(:render, portlet, portlet.assigns_for_liquid, liquid_options)
          surround_by_comments(context, 'PORTLET', portlet.system_name, content)
        end
      end

      private

      def find_portlet(context)
        # controller(context).send(:site_account).portlets.find_by_system_name!(@template_name).to_portlet
        context.registers[:file_system].find_portlet(@template_name).try(:to_portlet)
      end

    end
  end
end
