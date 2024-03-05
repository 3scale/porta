# This exists to prevent crashing old versions of
# lib/developer_portal/app/views/developer_portal/accounts/payment_gateways/show.html.liquid
# It can and should be removed since Authorize.Net was already deprecated and cleaned up.
module Liquid
  module Tags

    class AuthorizeNetForm < Liquid::Tags::PaymentGatewayBaseForm

      desc "Renders the authorize net form"
      # :reek:UnusedParameters
      def render(context); end
    end
  end
end
