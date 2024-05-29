module Admin::PaymentDetailsHelper
  def credit_card_stored_status(account, link_to_payment_gateway = false)

    txt = if account.credit_card_stored?
            ccexp = l account.credit_card_expires_on_with_default, format: :month

            if current_account.payment_gateway_type  != :authorize_net
              "Credit Card details are on file. Card expires in: #{ccexp}"
            else
              "Credit Card details are on file"
            end
          else
            'Credit Card details are not stored'
          end

    boolean_status_img(account.credit_card_stored?, :alt => txt) + ' ' +
      (link_to_payment_gateway ? link_to(txt, provider_admin_account_braintree_blue_url) : txt)
  end
end
