module Liquid
  module Drops
    class PaymentGateway < Base

      def initialize(account)
        @account = account
      end

      desc "Returns whether current payment gateway is authorize.Net."
      def braintree_blue?
        @account.payment_gateway_type == :braintree_blue
      end

      desc "Returns whether current payment gateway is authorize.Net."
      def authorize_net?
        @account.payment_gateway_type == :authorize_net
      end

      desc "Returns the type of the payment gateway."
      def type
        @account.payment_gateway_type.to_s
      end
    end
  end
end
