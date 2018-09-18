module Liquid
  module Tags

    class StripeForm < Liquid::Tags::PaymentGatewayBaseForm

      desc "Renders the stripe form"
      def render(context)
        render_erb context, "payment_gateways/stripe", text: @text
      end
    end
  end
end
