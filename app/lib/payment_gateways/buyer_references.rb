# frozen_string_literal: true

module PaymentGateways

  # BuyerReferences holds the references used on payment transactions.
  # The methods described below are used on Ogone.
  module BuyerReferences
    extend ActiveSupport::Concern

    module ClassMethods
      def buyer_reference(account, provider)
        "3scale-#{provider.id}-#{account.id}"
      end
    end

    # This method is used by Ogone
    #
    # +buyer_reference+ MUST be less than 80 characters
    #
    # An ID that uniquely identifies the buyer.
    # This +buyer_reference+ must not be changed. It is used for any subsequent payments.
    #
    # This value should be stored in <tt>Account['credit_card_auth_code']</tt>
    #
    # References:
    #
    # * On Ogone it is referred as <tt>alias</tt>
    def buyer_reference
      @buyer_reference ||= self.class.buyer_reference(account, provider)
    end

    extend ClassMethods
  end
end
