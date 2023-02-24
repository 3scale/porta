module Liquid
  module Drops
    class PaymentGateway < Base

      def initialize(account)
        @account = account
      end

      desc "Returns whether current payment gateway is Braintree."
      def braintree_blue?
        @account.payment_gateway_type == :braintree_blue
      end

      desc "Returns the type of the payment gateway."
      def type
        @account.payment_gateway_type.to_s
      end
    end
  end
end
