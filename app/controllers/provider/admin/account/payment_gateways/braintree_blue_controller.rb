class Provider::Admin::Account::PaymentGateways::BraintreeBlueController < Provider::Admin::Account::BaseController

  after_action :check_multiple_payment_failures, only: [:hosted_success]
  skip_before_action :protect_access
  before_action :authorize_finance
  before_action :find_account
  prepend_before_action :deny_on_premises
  activate_menu :account, :billing, :payment_details

  def show
  end

  def edit
    current_account.require_billing_information!
    redirect_to edit_provider_admin_account_path(next_step: 'credit_card') and return false unless current_account.valid?

    begin
      braintree_blue_crypt.create_customer_data
      @braintree_authorization = braintree_blue_crypt.authorization
    rescue Braintree::ConfigurationError, Braintree::AuthenticationError
      redirect_to({ action: :show }, danger: t('.invalid_merchant'))
    end
    @errors = params[:errors]
  end

  def update
    if current_account.update params.permit(:account)[:account]
      redirect_to provider_admin_account_braintree_blue_url, success: t('.success')
    else
      hack_errors
      render action: 'edit'
    end
  end

  def hosted_success
    customer_info      = params.require(:customer).permit!.to_h
    braintree_response = braintree_blue_crypt.confirm(customer_info, params.require(:braintree).require(:nonce))
    @payment_result    = braintree_response&.success?

    if @payment_result
      if braintree_blue_crypt.update_user(braintree_response)
        redirect_to_success
      else
        flash.now[:warning] = t('.credit_card_error')
        render action: 'edit'
      end
    else
      @errors = braintree_response ? braintree_blue_crypt.errors(braintree_response) : ['Invalid Credentials']
      redirect_to({ action: :edit, errors: @errors }, danger: t('.billing_address_error')) # @errors what for?
    end
  end

  def destroy
    # TODO: should we notify somehow when #unstore_credit_card! returned a failure response?
    current_account.unstore_credit_card!
    current_account.delete_billing_address
    current_account.save
    redirect_to({ action: :show }, success: t('.success'))
  end

  private

  def check_multiple_payment_failures
    Payment::MultipleFailureChecker.new(current_account, @payment_result, user_session).call
  end

  def braintree_blue_crypt
    @braintree_blue_crypt ||= ::PaymentGateways::BrainTreeBlueCrypt.new(current_user)
  end

  def redirect_to_success
    flash[:success] = t('.success')
    if params[:next_step] == 'upgrade_plan'
      redirect_to provider_admin_account_path(next_step: 'upgrade_plan')
    else
      redirect_to provider_admin_account_braintree_blue_path
    end
  end

  def find_account
    @account = current_account
  end

  def authorize_finance
    authorize! :manage, :credit_card
  end

  # Move errors from billing_address to account to avoid *billing_address_*address1 stuff.
  # this hackish thing converts the errors from Account the BillingAddress class
  def hack_errors
    current_account.billing_address.errors = current_account.errors

    new_errors = {}
    current_account.billing_address.errors.messages.each do |k,v|
      new_errors[k.to_s.gsub('billing_address_','')] = v
    end

    current_account.billing_address.errors.instance_variable_set('@errors', new_errors)
  end
end
