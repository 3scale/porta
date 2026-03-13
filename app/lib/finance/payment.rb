module Finance
  module Payment
    class CreditCardError < RuntimeError; end
    class CreditCardMissing < CreditCardError ; end
    class CreditCardExpired < CreditCardError ; end

    class GatewayError < CreditCardError
      attr_reader :response

      def initialize(response = nil)
        @response = response
      end

      def message
        response.try!(:message) || super
      end
    end

    CreditCardPurchaseFailed = Class.new(GatewayError)

    # Rate limit error - should be retried immediately, not treated as payment failure
    class StripeRateLimitError < ActiveMerchant::ActiveMerchantError
      attr_reader :response, :payment_metadata

      def initialize(response, payment_metadata)
        @response = response
        @payment_metadata = payment_metadata
      end

      def message
        response.try!(:message) || 'Rate limit exceeded - too many requests to payment gateway'
      end
    end
  end
end
