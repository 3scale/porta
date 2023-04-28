class Admin::Api::CreditCardsController < Admin::Api::BaseController

  self.access_token_scopes = %i[finance account_management]

  before_action :find_buyer

  # Account Set Credit Card
  # PUT /admin/api/accounts/{id}/credit_card.xml
  def update
    forced_parameters = :credit_card_token, :account_id, :billing_address_name, :billing_address_address,
                        :billing_address_city, :billing_address_country, :credit_card_expiration_year,
                        :credit_card_expiration_month

    if @buyer.provider_account.payment_gateway_type == :authorize_net
      forced_parameters <<  :credit_card_authorize_net_payment_profile_token
    end

    failed = nil
    unless failed = required_params(forced_parameters)

      @buyer.credit_card_auth_code = params[:credit_card_token]

      @buyer.credit_card_authorize_net_payment_profile_token =
        params[:credit_card_authorize_net_payment_profile_token]

      @buyer.billing_address_name = params[:billing_address_name]
      @buyer.billing_address_address1 = params[:billing_address_address]

      @buyer.billing_address_city = params[:billing_address_city]
      @buyer.billing_address_country = params[:billing_address_country]

      @buyer.credit_card_partial_number = params[:credit_card_partial_number]
      @buyer.billing_address_state = params[:billing_address_state]
      @buyer.billing_address_phone = params[:billing_address_phone]
      @buyer.billing_address_zip = params[:billing_address_zip]

      begin
        @buyer.credit_card_expires_on_month = params[:credit_card_expiration_month]
      rescue  ArgumentError => e
        failed = "credit_card_expiration_month"
        @buyer.errors.add(:credit_card_expires_on)
      end

      begin
        @buyer.credit_card_expires_on_year = params[:credit_card_expiration_year]
      rescue ArgumentError => e
        failed = "credit_card_expiration_year"
        @buyer.errors.add(:credit_card_expires_on)
      end
    else
      # TODO: this will return a misleading error message
      real_names = {
        :credit_card_token => :credit_card_auth_code ,
        :billing_address_address => :billing_address_address1
      }
      @buyer.errors.add(real_names.fetch(failed.to_sym, failed.to_sym))
    end

    @buyer.save unless failed

    respond_with(@buyer)
  end

  # Account Delete Credit Card
  # DELETE /admin/api/accounts/{id}/credit_card.xml
  def destroy
    failed = nil
    unless failed = required_params(:account_id)
      @buyer.delete_cc_details
      @buyer.delete_billing_address
    else
      @buyer.errors.add(failed.to_sym)
    end

    @buyer.save unless failed

    respond_with(@buyer)
  end

  protected

  def find_buyer
    @buyer = current_account.buyers.find(params[:account_id])
  end
end
