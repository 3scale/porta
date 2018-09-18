# frozen_string_literal: true

class Provider::Admin::Redhat::AuthController < Provider::AdminController
  include SiteAccountSupport
  include RedhatCustomerPortalSupport::ControllerMethods::AuthFlow

  layout 'provider'

  def show
    user_data = oauth_client.authenticate!(params[:code], request)

    if update_redhat_login(user_data)
      flash[:notice] = 'The Red Hat Login was linked to the account'
    else
      flash[:error] = extract_error_message_from(user_data)
    end

    redirect_to referrer_url
  end

  protected

  def oauth_client
    @oauth_client ||= ThreeScale::OAuth2::Client.build(authentication_provider)
  end

  def authentication_provider
    @authentication_provider ||= current_account.redhat_customer_authentication_provider
  end

  def referrer_url
    url = params[:referrer]
    if url
      URI.decode(url)
    else
      provider_admin_account_path
    end
  end

  def update_redhat_login(user_data)
    return unless user_data.is_a?(ThreeScale::OAuth2::UserData) # nasty type checking

    username = oauth_client.raw_info['RHAT_LOGIN'].presence || user_data.username
    extra_fields = {
      'red_hat_account_number' => username,
      'red_hat_account_verified_by' => current_user.username
    }
    current_account.update_attributes(extra_fields: extra_fields)
  end

  def extract_error_message_from(user_data)
    return user_data.error if user_data.is_a?(ThreeScale::OAuth2::ErrorData) # user_data.respond_to(:error) ?

    account_errors = current_account.errors
    return account_errors.full_messages.to_sentence if account_errors.any?

    raise_client_error('Unknown response from OAuth Authentication', user_data: user_data.to_h)
  end

  def raise_client_error(error_message, opts = {})
    authentication = oauth_client.authentication
    metadata = {
      system_name: authentication.system_name,
      account: authentication.account.attributes,
      params: request.params
    }.merge(opts)
    raise(ThreeScale::OAuth2::ClientBase::ClientError.new(error_message, metadata))
  end
end
