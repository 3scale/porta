# frozen_string_literal: true

class Admin::Api::AuthenticationProvidersController < Admin::Api::BaseController
  wrap_parameters :authentication_provider
  represents :json, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::JSON
  represents :xml, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::XML

  before_action :find_authentication_provider, only: %i[update show]
  before_action :authorize_authentication_provider, only: %i[update show]


  # Authentication Provider Developer Portal Create
  # POST /admin/api/authentication_providers.xml
  def create
    build_authentication_provider
    authorize_authentication_provider
    authentication_provider.save
    respond_with authentication_provider_presenter
  end

  # Authentication Provider Developer Portal Update
  # PUT /admin/api/authentication_providers/{id}.xml
  def update
    authentication_provider.update(authentication_provider_update_params)
    respond_with authentication_provider_presenter
  end

  # Authentication Providers Developer Portal List
  # GET /admin/api/authentication_providers.xml
  def index
    presenters = OauthFlowPresenter.wrap(authentication_providers, request)
    respond_with(presenters)
  end

  # Authentication Provider Read
  # GET /admin/api/authentication_providers/{id}.xml
  def show
    respond_with authentication_provider_presenter
  end

  private

  attr_reader :authentication_provider

  def authentication_providers
    @authentication_providers ||= current_account.authentication_providers
  end

  def find_authentication_provider
    @authentication_provider ||= authentication_providers.find(params[:id])
  end

  def authentication_provider_presenter
    OauthFlowPresenter.new(authentication_provider, request)
  end

  def build_authentication_provider
    attributes = authentication_provider_create_params
    @authentication_provider = authentication_providers.build_kind(kind: attributes.require(:kind), **attributes.to_h.symbolize_keys)
  end

  def authorize_authentication_provider
    scope = authentication_provider.authorization_scope(action_name)
    authorize!(:manage, scope) if scope
  end

  def authentication_provider_create_params
    params.require(:authentication_provider).permit(
      :name, :system_name, :client_id, :client_secret,
      :token_url, :user_info_url, :authorize_url, :site,
      :identifier_key, :username_key, :trust_email, :kind,
      :published, :branding_state_event, :skip_ssl_certificate_verification,
      :automatically_approve_accounts
    )
  end

  def authentication_provider_update_params
    params.require(:authentication_provider).permit(
      :client_id, :client_secret, :published, :site,
      :skip_ssl_certificate_verification, :automatically_approve_accounts
    )
  end
end
