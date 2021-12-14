# frozen_string_literal: true

class Provider::Admin::AuthenticationProvidersController < FrontendController
  before_action :authorize_settings

  activate_menu :audience, :cms, :sso_integrations
  sublayout 'sites/developer_portals'

  before_action :find_authentication_provider, only: %i[show edit update publish_or_hide destroy]
  before_action :authorize_authentication_provider, only: %i[show edit destroy]

  def index
    @authentication_providers = current_account.authentication_provider_kinds
  end

  def new
    find_or_build_authentication_provider
    authorize_authentication_provider
    if @authentication_provider.persisted? || @authentication_provider.save
      redirect_to provider_admin_authentication_provider_path(@authentication_provider)
    else
      @authentication_provider.errors.clear
    end
  end

  def show
    @oauth_presenter = OauthFlowPresenter.new(@authentication_provider, request)
  end

  def create
    build_authentication_provider
    authorize_authentication_provider
    if @authentication_provider.save
      redirect_to edit_provider_admin_authentication_provider_path(@authentication_provider), notice: 'Authentication provider created'
    else
      render 'new'
    end
  end

  def edit; end

  def publish_or_hide
    authorize_authentication_provider('update')
    published = params.require(:authentication_provider).require(:published)
    persisted = @authentication_provider.update_attributes({published: published})
    flash[:notice] = persisted ? 'Authentication provider updated' : 'Authentication provider has not been updated'
    @oauth_presenter = OauthFlowPresenter.new(@authentication_provider, request)
    render :show
  end

  def update
    authorize_authentication_provider('edit')
    persisted = @authentication_provider.update_attributes(update_params)
    if persisted
      flash[:notice] = 'Authentication provider updated'
      @oauth_presenter = OauthFlowPresenter.new(@authentication_provider, request)
      render :show
    else
      flash[:notice] = 'Authentication provider has not been updated'
      render :edit
    end
  end

  def destroy
    @authentication_provider.destroy
    redirect_to provider_admin_authentication_providers_path, notice: 'Authentication provider deleted'
  end

  private

  attr_reader :authentication_provider

  def authentication_providers
    @authentication_providers ||= current_account.authentication_providers
  end

  def find_authentication_provider
    @authentication_provider ||= authentication_providers.find(params[:id])
  end

  def find_or_build_authentication_provider
    kind = params[:kind].presence
    @authentication_provider = authentication_providers.find_by(kind: kind) || authentication_providers.build_kind(kind: kind)
  end

  def build_authentication_provider
    @authentication_provider = authentication_providers.build_kind(kind: create_params.require(:kind), **create_params.to_h.symbolize_keys)
  end

  def authorize_authentication_provider(action = action_name)
    scope = authentication_provider.authorization_scope(action)
    authorize!(:manage, scope) if scope
  end

  UPDATE_PARAMS = %i[client_id client_secret automatically_approve_accounts site
                     realm skip_ssl_certificate_verification branding_state_event
                     token_url authorize_url user_info_url identifier_key
                     username_key trust_email].freeze

  def update_params
    params.require(:authentication_provider).permit(UPDATE_PARAMS)
  end

  def create_params
    permitted_params = UPDATE_PARAMS + %i[name system_name kind published]
    params.require(:authentication_provider).permit(permitted_params)
  end

  protected

  def authorize_settings
    authorize! :manage, :settings
  end
end
