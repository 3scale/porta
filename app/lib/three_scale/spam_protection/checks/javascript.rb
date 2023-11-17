module ThreeScale::SpamProtection
  module Checks

    class Javascript < Base
      def input(form)
        template = form.template

        yes = template.text_field_tag :javascript, '1', hidden: true
        no = template.text_field_tag :javascript, '0', hidden: true

        js = %{document.write("#{template.escape_javascript(yes)}");}

        output = "".html_safe
        output << template.javascript_tag(js)
        output << template.content_tag(:noscript){ no.html_safe }
        form.template.tag.li output, class: "hidden"
      end

      def probability(object)
        case value = object.params[:javascript]
        when "1" # javascript is working
          add_to_average(0)
        when "0" # noscript tag is working
          fail_check(value, 0.6)
        else # something different happened
          raise SpamDetectedError # Immediately marks as bot
        end
      end
    end

  end
end
