module DeveloperPortal
  module ControllerMethods
    module PaymentPathsMethods
      protected

      def hosted_success_payment_url(merchant_account = site_account)
        return '' if unacceptable_payment_gateway?(merchant_account)
        polymorphic_url([:hosted, :success, :admin, :account, merchant_account.payment_gateway_type])
      end

      def payment_details_path(merchant_account = site_account)
        return '' if unacceptable_payment_gateway?(merchant_account)
        polymorphic_path([:admin, :account, merchant_account.payment_gateway_type])
      end

      def edit_payment_details_path(merchant_account = site_account)
        return '' if unacceptable_payment_gateway?(merchant_account)
        polymorphic_path([:edit, :admin, :account, merchant_account.payment_gateway_type])
      end

      def unacceptable_payment_gateway?(merchant_account)
        ['bogus', ''].include?(merchant_account.payment_gateway_type.to_s)
      end
    end
  end
end
