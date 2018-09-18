module Liquid
  module Tags

    class PaymentExpressForm < Liquid::Tags::PaymentGatewayBaseForm
      hidden
      desc "Renders the payment express form"
      deprecated "The Payment Express gateway is no longer supported"
      def render
        ''
      end
    end
  end
end
