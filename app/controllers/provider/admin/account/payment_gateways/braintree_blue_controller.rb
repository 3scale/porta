class Provider::Admin::Account::PaymentGateways::BraintreeBlueController < Provider::Admin::Account::BaseController

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
      @form_url = braintree_blue_crypt.form_url
      @tr_data = braintree_blue_crypt.create_customer_data(
        :redirect_url => hosted_success_provider_admin_account_braintree_blue_url(next_step: params[:next_step]))
    rescue Braintree::ConfigurationError, Braintree::AuthenticationError
      flash[:error] = 'Invalid merchant id'
      redirect_to action: 'show'
    end
    @errors = params[:errors]
  end

  def update
    current_account.updating_payment_detail = true
    if current_account.update_attributes params[:account]
      redirect_to provider_admin_account_braintree_blue_url, notice: 'Credit card details were successfully stored.'
    else
      hack_errors
      render action: 'edit'
    end
  end

  def hosted_success
    result = braintree_blue_crypt.confirm(request)

    if result && result.success?

      if braintree_blue_crypt.update_user(result)
        redirect_to_success
      else
        flash[:notice] = 'Credit Card details could not be stored.'
        render action: 'edit'
      end

    else
      @errors = result ? braintree_blue_crypt.errors(result) : ['Invalid Credentials']
      flash[:error] = 'Something went wrong and billing information could not be stored.'
      redirect_to action: 'edit', errors: @errors
    end
  end

  def destroy
    current_account.unstore_credit_card!
    current_account.delete_billing_address
    current_account.save
    flash[:notice] = 'Your credit card was successfully removed'
    redirect_to action: 'show'
  end

  private

  def braintree_blue_crypt
    @braintree_blue_crypt ||= ::PaymentGateways::BrainTreeBlueCrypt.new(current_user)
  end

  def redirect_to_success
    flash[:notice] = 'Credit card details were successfully stored.'
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
