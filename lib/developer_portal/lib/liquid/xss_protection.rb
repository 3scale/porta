module Liquid::XssProtection

  def to_s
    ERB::Util.html_escape(super.dup)
  end

  def to_str
    ERB::Util.html_escape(super.dup)
  end

  def self.enable!
    Liquid::Variable.class_eval do
      next if method_defined?(:render_with_html_escape)

      def render_with_html_escape(context)
        output = render_without_html_escape(context)
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

      alias_method_chain :render, :html_escape
    end
  end
end
