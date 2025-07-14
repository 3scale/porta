# frozen_string_literal: true

class Provider::Admin::Account::AuthenticationProvidersController < Provider::Admin::Account::BaseController
  before_action :authorize_rolling_update!
  before_action :authorize_changes, only: [:edit, :update, :destroy]
  activate_menu :account, :users, :sso_integrations

  before_action :disable_client_cache

  attr_reader :presenter

  helper_method :presenter

  def index
    @presenter = Provider::Admin::Account::AuthenticationProvidersIndexPresenter.new(
      user: current_user,
      authentication_providers: self_authentication_providers,
      session: user_session,
      params: params)
  end

  def new
    @authentication_provider = self_authentication_providers.new
  end

  def create
    attributes = authentication_provider_params
    @authentication_provider = self_authentication_providers.build_kind(kind: attributes.require(:kind), **attributes.to_h.symbolize_keys)

    if @authentication_provider.save
      redirect_to provider_admin_account_authentication_provider_path(@authentication_provider), success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render 'new'
    end
  end

  def show
    @presenter = Provider::Admin::Account::AuthenticationProvidersShowPresenter.new(authentication_provider)
    @oauth_presenter = ProviderOAuthFlowPresenter.new(authentication_provider, request, request.host)
  end

  def edit
    @authentication_provider = authentication_provider
  end

  def update
    @authentication_provider = authentication_provider

    if @authentication_provider.update(authentication_provider_params)
      redirect_to provider_admin_account_authentication_provider_path(@authentication_provider), success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :edit
    end
  end

  def destroy
    authentication_provider.destroy
    flash[:success] = t('.success')
    path = provider_admin_account_authentication_providers_path

    respond_to do |format|
      format.html { redirect_to path }
      format.json { render json: { redirect: path } }
    end
  end

  private

  def self_authentication_providers
    @self_authentication_providers ||= current_account.self_authentication_providers
  end

  def authentication_provider
    self_authentication_providers.find(params.require(:id))
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

    error = t('.authorize_changes.error')
    respond_to do |format|
      format.html do
        redirect_to provider_admin_account_authentication_providers_path, danger: error
      end
      format.json { render json: { error: error } }
    end
  end

  def can_edit?
    return true unless current_account.settings.enforce_sso?

    !authentication_provider.published?
  end
end
