module Liquid
  module Tags

    class Adyen12Form < Liquid::Tags::PaymentGatewayBaseForm

      desc "Renders the Adyen form"
      def render(context)
        render_erb context, "payment_gateways/adyen12", text: @text
      end
    end
  end
end
