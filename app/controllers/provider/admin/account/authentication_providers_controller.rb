class Provider::Admin::Account::AuthenticationProvidersController < Provider::Admin::Account::BaseController
  before_action :authorize_rolling_update!
  before_action :authorize_changes, only: [:edit, :update, :destroy]
  activate_menu :account, :users, :sso_integrations

  def index
    @presenter = Provider::Admin::Account::AuthenticationProvidersIndexPresenter.new(
      current_user, self_authentication_providers, user_session)
  end

  def new
    @authentication_provider = self_authentication_providers.new
  end

  def create
    attributes = authentication_provider_params
    @authentication_provider = self_authentication_providers.build_kind(kind: attributes.require(:kind), **attributes.symbolize_keys)

    if @authentication_provider.save
      redirect_to provider_admin_account_authentication_provider_path(@authentication_provider), notice: 'SSO integration created'
    else
      flash.now[:error] = 'SSO integration could not be created'
      render 'new'
    end
  end

  def show
    @presenter = Provider::Admin::Account::AuthenticationProvidersShowPresenter.new(authentication_provider)
    @oauth_presenter = ProviderOauthFlowPresenter.new(authentication_provider, request, request.host)
  end

  def edit
    @authentication_provider = authentication_provider
  end

  def update
    @authentication_provider = authentication_provider

    if @authentication_provider.update_attributes(authentication_provider_params)
      redirect_to provider_admin_account_authentication_provider_path(@authentication_provider), notice: 'SSO integration updated'
    else
      flash.now[:error] = 'SSO integration could not be updated'
      render :edit
    end
  end

  def destroy
    authentication_provider.destroy
    redirect_to provider_admin_account_authentication_providers_path, notice: 'SSO integration deleted'
  end

  private

  def self_authentication_providers
    @self_authentication_providers ||= current_account.self_authentication_providers
  end

  def authentication_provider
    self_authentication_providers.find(params[:id])
  end

  def authorize_rolling_update!
    provider_can_use!(:provider_sso)
  end

  def authentication_provider_params
    params.require(:authentication_provider).permit(
      :client_id, :client_secret,
      :site, :realm, :kind,
      :skip_ssl_certificate_verification
    )
  end

  def authorize_changes
    return if can_edit?

    flash[:error] = 'You cannot edit active SSO Providers when SSO is enforced'
    redirect_to provider_admin_account_authentication_providers_path
  end

  def can_edit?
    return true unless current_account.settings.enforce_sso?

    !authentication_provider.published?
  end
end
