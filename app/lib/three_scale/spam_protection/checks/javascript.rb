module ThreeScale::SpamProtection
  module Checks

    class Javascript < Base
      def input(form)
        template = form.template

        yes = form.input :javascript, :as => :hidden, :value => '1', :wrapper_html => { :style => HIDE_STYLE }
        no = form.input :javascript, :as => :hidden, :value => '0', :wrapper_html => { :style => HIDE_STYLE }

        js = %{document.write("#{template.escape_javascript(yes)}");}

        output = "".html_safe
        output << template.javascript_tag(js)
        output << template.content_tag(:noscript){ no.html_safe }
        output
      end

      def probability(object)
        case value = object.javascript
        when "1" # javascript is working
          0
        when "0" # noscript tag is working
          fail(value, 0.6)
        else # something different happened
          fail(value)
        end
      end

      def apply!(klass)
        klass.class_eval do
          attr_accessor :javascript
          spam_protection_attribute :javascript
        end
      end

    end

  end
end
