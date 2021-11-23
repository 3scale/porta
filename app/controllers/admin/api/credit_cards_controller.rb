class Admin::Api::CreditCardsController < Admin::Api::BaseController

  self.access_token_scopes = %i[finance account_management]

  before_action :find_buyer

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{id}/credit_card.xml"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Account Set Credit Card"
  ##~ op.description = "Associates credit card tokens and billing address to an account. This operation is only required if you use your own credit card capture method. These tokens are the ones required by Authorize.net, ogone, braintree, payment express and merchant e solutions"
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "credit_card_token", :description => "Token used by the payment gateway to identify the buyer, customer profile ID (Authorize.net), customer ID (Braintree and Stripe), customer alias (Ogone-Ingenico). Some payment gateways may store more than one card under the same buyer reference and/or require an additional identifier for recurring payment. If you are using Braintree, there is no need for additional identifier -- the first credit card available will always be charged. For Authorize.net, see `credit_card_authorize_net_payment_profile_token`."
  ##~ op.parameters.add :dataType => "string", :required => false, :paramType => "query", :name => "credit_card_authorize_net_payment_profile_token", :description => "Additional reference provided by the payment gateway to identify a specific card under the same buyer reference. For Authorize.net, you MUST fill with the 'Payment profile token'"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "credit_card_expiration_year", :description => "Year of expiration of credit card. Two digit number"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "credit_card_expiration_month", :description => "Month of expiration of credit card. Two digit number"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "billing_address_name", :description => "Name of the person/company to bill"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "billing_address_address", :description => "Address associated to the credit card"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "billing_address_city", :description => "Billing address city"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "query", :name => "billing_address_country", :description => "Billing address country"

  ##~ op.parameters.add :dataType => "string", :paramType => "query", :name => "billing_address_state", :description => "Billing address state", :required => false
  ##~ op.parameters.add :dataType => "string", :paramType => "query", :name => "billing_address_phone", :description => "Billing address phone", :required => false
  ##~ op.parameters.add :dataType => "string", :paramType => "query", :name => "billing_address_zip", :description => "Billing address ZIP Code", :required => false
  ##~ op.parameters.add :dataType => "string", :paramType => "query", :name => "credit_card_partial_number", :description => "Last four digits on the credit card"

  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token" }

  def update
    forced_parameters = :credit_card_token, :account_id, :billing_address_name, :billing_address_address,
                        :billing_address_city, :billing_address_country, :credit_card_expiration_year,
                        :credit_card_expiration_month

    if @buyer.provider_account.payment_gateway_type == :authorize_net
      forced_parameters <<  :credit_card_authorize_net_payment_profile_token
    end


    params.require(forced_parameters)

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
    rescue  ArgumentError
      @buyer.errors.add(:credit_card_expiration_month)
      @buyer.errors.add(:credit_card_expires_on)
    end

    begin
      @buyer.credit_card_expires_on_year = params[:credit_card_expiration_year]
    rescue ArgumentError
      @buyer.errors.add(:credit_card_expiration_year)
      @buyer.errors.add(:credit_card_expires_on)
    end

    @buyer.save

    respond_with(@buyer)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary = "Account Delete Credit Card"
  ##~ op.description = "Removes all credit card info of an account."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id

  def destroy
    @buyer.delete_cc_details
    @buyer.delete_billing_address
    @buyer.save

    respond_with(@buyer)
  end

  protected

  def find_buyer
    @buyer = current_account.buyers.find(params.require(:account_id))
  end
end
