module Liquid
  module Tags

    class AuthorizeNetForm < Liquid::Tags::PaymentGatewayBaseForm

      desc "Renders the authorize net form"
      def render(context)
        render_erb context, "payment_gateways/authorize_net", text: @text
      end
    end
  end
end
