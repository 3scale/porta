# frozen_string_literal: true

module Liquid::XssProtection

  def to_s
    ERB::Util.html_escape(super.dup)
  end

  def to_str
    ERB::Util.html_escape(super.dup)
  end

  module Renderer
    def render(context)
      output = super(context)
      should_escape = context.registers[:escape_html] && !output.html_safe?

      if should_escape && output.respond_to?(:to_str)
        output = output.dup.extend(Liquid::XssProtection)
      end

      case output
      when String
        output.to_str
      else
        output
      end
    end

    alias render_with_html_escape render
  end

  def self.enable!
    Liquid::Variable.class_eval do
      next if method_defined?(:render_with_html_escape)

      prepend Renderer

    end
  end
end
