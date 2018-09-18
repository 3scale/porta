module Liquid::Tags
  class ContentFor < Liquid::Block

    extend Liquid::Docs::DSL::Tags

    Syntax = /(\w+)/

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @name = $1
      else
        raise SyntaxError.new("Syntax Error in 'content_for' - Valid syntax: content_for [var]")
      end

      super
    end

    def render(context)
      content_for = context.registers.fetch(:content_for)
      # TODO: in "dev" mode print the output as html comment
      content_for[@name] = super
      ''
    end

    module ContentFor
      def stylesheets
        Liquid::Template.parse("{{ content_of.stylesheets | html_safe }}")
      end

      def javascripts
        Liquid::Template.parse("{{ content_of.javascripts | html_safe }}")
      end
    end

  end
end
