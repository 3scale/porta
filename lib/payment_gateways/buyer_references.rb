module PaymentGateways

  # BuyerReferences holds the references used on payment transactions.
  # The methods described below are used on Adyen12 and Ogone.
  module BuyerReferences
    extend ActiveSupport::Concern

    module ClassMethods
      def buyer_reference(account, provider)
        "3scale-#{provider.id}-#{account.id}"
      end

      # This method is used by Adyen12
      #
      # +charge_reference+ MUST be less than 80 characters
      #
      # Use this method to fill in the <tt>reference</tt> field in Adyen request when charging.
      def charge_reference(account, invoice)
        "3scale-charge-invoice-#{invoice.id}-#{account.id}"
      end

      # This method is used by Adyen12
      #
      # +recurring_authorization_reference+ MUST be less than 80 characters
      #
      # Use this method to fill in the <tt>reference</tt> field in Adyen request when creating the recurring contract.
      def recurring_authorization_reference(account, provider)
        "3scale-recurring-authorization-#{provider.id}-#{account.id}"
      end
    end

    # This method is used by Adyen12
    #
    # +recurring_authorization+ MUST be less than 80 characters
    #
    # This refers to the <tt>reference</tt> label of recurring contract creation.
    #
    # References:
    #
    # * On Adyen12 it is referred as <tt>reference</tt>
    def recurring_authorization_reference
      @recurring_authorization_reference ||= self.class.recurring_authorization_reference(account, provider)
    end

    # This method is used by Adyen12 and Ogone
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
    # * On Adyen12 it is referred as <tt>shopperReference</tt>
    # * On Ogone it is referred as <tt>alias</tt>
    def buyer_reference
      @buyer_reference ||= self.class.buyer_reference(account, provider)
    end

    extend ClassMethods
  end
end
