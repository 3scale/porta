# frozen_string_literal: true

# This exists to prevent crashing old versions of
# lib/developer_portal/app/views/developer_portal/accounts/payment_gateways/show.html.liquid
# It can and should be removed since Ogone was already deprecated and cleaned up.
module Liquid
  module Tags
    class OgoneForm < Liquid::Tags::PaymentGatewayBaseForm
      def render(context); end
    end
  end
end
