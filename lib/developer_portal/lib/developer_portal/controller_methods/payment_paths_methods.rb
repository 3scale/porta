# frozen_string_literal: true

module DeveloperPortal
  module ControllerMethods
    module PaymentPathsMethods
      protected

      def hosted_success_payment_url(merchant_account = site_account)
        return '' if merchant_account.unacceptable_payment_gateway?

        polymorphic_url([:hosted, :success, :admin, :account, merchant_account.payment_gateway_type])
      end

      def payment_details_path(merchant_account = site_account)
        return '' if merchant_account.unacceptable_payment_gateway?

        polymorphic_path([:admin, :account, merchant_account.payment_gateway_type])
      end

      def edit_payment_details_path(merchant_account = site_account)
        return '' if merchant_account.unacceptable_payment_gateway?

        polymorphic_path([:edit, :admin, :account, merchant_account.payment_gateway_type])
      end
    end
  end
end
