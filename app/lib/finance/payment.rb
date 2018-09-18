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

  end
end
