# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::AuthController < Provider::AdminController
  include SiteAccountSupport
  layout 'provider'

  def show
    data = oauth_client.authenticate!(params[:code], request)

    # This should save token in the database for future use:
    # - backround job
    # - retrieving the namespaces, services in the cluster controller

    case data
    when ThreeScale::OAuth2::UserData
      current_user.provided_access_tokens.create_from_access_token!(oauth_client.access_token)
      redirect_options = { success: 'You can now use the service discovery' }
    else
      redirect_options = { error: 'We could not authenticate you against OpenShift cluster' }
    end
    redirect_to referrer_url, redirect_options
  end

  protected

  def oauth_client
    @oauth_client ||= ThreeScale::OAuth2::Client.build(authentication_provider)
  end

  def authentication_provider
    @authentication_provider ||= current_account.service_discovery_authentication_provider
  end

  def referrer_url
    url = params[:referrer]
    if url
      URI.decode(url)
    else
      new_admin_service_path
    end
  end
end
