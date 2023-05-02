# frozen_string_literal: true

class Admin::Api::Account::AuthenticationProvidersController < Admin::Api::BaseController
  wrap_parameters :authentication_provider
  represents :json, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::JSON
  represents :xml, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::XML

  before_action :authorize_rolling_update
  before_action :find_authentication_provider, only: %i[update show]

  # Authentication Provider Admin Portal Create
  # POST /admin/api/account/authentication_providers.xml
  def create
    attributes = authentication_provider_create_params
    @authentication_provider = self_authentication_providers.build_kind(kind: attributes.require(:kind), **attributes.to_h.symbolize_keys)
    authentication_provider.save
    respond_with authentication_provider_presenter
  end

  # Authentication Provider Admin Portal Update
  # PUT /admin/api/account/authentication_providers/{id}.xml
  def update
    authorize_changes
    authentication_provider.update_attributes(authentication_provider_update_params)
    respond_with authentication_provider_presenter
  end

  # Authentication Providers Admin Portal List
  # GET /admin/api/account/authentication_providers.xml
  def index
    presenters = ProviderOAuthFlowPresenter.wrap(self_authentication_providers, request, request.host)
    respond_with(presenters)
  end

  # Authentication Provider Admin Portal Read
  # GET /admin/api/account/authentication_providers/{id}.xml
  def show
    respond_with authentication_provider_presenter
  end

  private

  attr_reader :authentication_provider

  def self_authentication_providers
    @self_authentication_providers ||= current_account.self_authentication_providers
  end

  def find_authentication_provider
    @authentication_provider ||= self_authentication_providers.find(params[:id])
  end

  def authentication_provider_presenter
    ProviderOAuthFlowPresenter.new(authentication_provider, request, request.host)
  end

  def authorize_rolling_update
    provider_can_use!(:provider_sso)
  end

  def authorize_changes
    return unless current_account.settings.enforce_sso? && authentication_provider.published?
    raise CanCan::AccessDenied
  end

  DEFAULT_PARAMS = %i[client_id client_secret site skip_ssl_certificate_verification published].freeze

  def authentication_provider_create_params
    params.require(:authentication_provider).permit(DEFAULT_PARAMS | %i[kind system_name name])
  end

  def authentication_provider_update_params
    params.require(:authentication_provider).permit(DEFAULT_PARAMS)
  end
end
