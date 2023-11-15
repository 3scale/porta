module ThreeScale::SpamProtection
  module Checks

    class Honeypot < Base
      def input(form)
        output = form.template.tag.input type: :hidden, name: :confirmation, value: "0"
        output << form.template.check_box_tag(:confirmation, "1", false)
        form.template.tag.li output, style: HIDE_STYLE
      end

      def probability(object)
        case object.params[:confirmation]
        when "0"
          add_to_average(0)
        else
          raise SpamCheckError # Immediately marks as bot
        end
      end
    end

  end
end
