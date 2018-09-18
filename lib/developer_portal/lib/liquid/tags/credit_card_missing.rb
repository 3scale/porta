module Liquid
  module Tags

    class CreditCardMissing < Base
      nodoc!

      # they can do this themselves, scheduled for deletion
      def render(context)
        render_erb context, "shared/credit_card_missing"
      end

    end

  end
end
