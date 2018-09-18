module Liquid
  module Tags

    class OgoneForm < Liquid::Tags::PaymentGatewayBaseForm

      desc "Renders the ogone form"
      def render(context)
        render_erb context, "payment_gateways/ogone", text: @text
      end
    end
  end
end
