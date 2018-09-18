module Liquid
  module Tags

    class BraintreeCustomerForm < Liquid::Tags::Base

      desc "Renders a form to enter data required for Braintree Blue payment gateway."
      def render(context)
        render_erb context, "payment_gateways/braintree_customer_form"
      end
    end
  end
end
