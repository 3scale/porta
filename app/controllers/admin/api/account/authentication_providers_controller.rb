# frozen_string_literal: true

class Admin::Api::Account::AuthenticationProvidersController < Admin::Api::BaseController
  wrap_parameters :authentication_provider
  represents :json, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::JSON
  represents :xml, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::XML

  before_action :authorize_rolling_update
  before_action :find_authentication_provider, only: %i[update show]

  ##~ @parameter_authentication_provider_id_by_id = {:name => "id", :description => "ID of the authentication provider.", :dataType => "string", :required => true, :paramType => "path"}
  ##~ @parameter_authentication_provider_admin_kind_required = {:name => "kind", :description => "The kind of authentication provider which can be either 'auth0' or 'keycloak'. Use 'keycloak' for Red Hat Single Sign-On.", :dataType => "string", :required => true, :paramType => "query"}
  ##~ @parameter_authentication_provider_name = {:name => "name", :description => "Name of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_system_name = {:name => "system_name", :description => "System Name of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_client_id = {:name => "client_id", :description => "Client ID of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_client_secret = {:name => "client_secret", :description => "Client Secret of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_site = {:name => "site", :description => "Site or Realm of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_skip_ssl_certificate_verification = {:name => "skip_ssl_certificate_verification", :description => "Skip SSL certificate verification. False by default.", :dataType => "boolean", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_published = {:name => "published", :description => "Published authentication provider. False by default", :dataType => "boolean", :required => false, :paramType => "query"}

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account/authentication_providers.xml"
  ##~ e.responseClass = "authentication_provider"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Authentication Provider Admin Portal Create"
  ##~ op.description = "Creates an authentication provider for the admin portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_authentication_provider_admin_kind_required
  ##~ op.parameters.add @parameter_authentication_provider_name
  ##~ op.parameters.add @parameter_authentication_provider_system_name
  ##~ op.parameters.add @parameter_authentication_provider_client_id
  ##~ op.parameters.add @parameter_authentication_provider_client_secret
  ##~ op.parameters.add @parameter_authentication_provider_site
  ##~ op.parameters.add @parameter_authentication_provider_skip_ssl_certificate_verification
  ##~ op.parameters.add @parameter_authentication_provider_published
  #
  def create
    attributes = authentication_provider_create_params
    @authentication_provider = self_authentication_providers.build_kind(kind: attributes.require(:kind), **attributes.symbolize_keys)
    authentication_provider.save
    respond_with authentication_provider_presenter
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account/authentication_providers/{id}.xml"
  ##~ e.responseClass = "authentication_provider"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Authentication Provider Admin Portal Update"
  ##~ op.description = "Updates an authentication provider for the admin portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_authentication_provider_id_by_id
  ##~ op.parameters.add @parameter_authentication_provider_client_id
  ##~ op.parameters.add @parameter_authentication_provider_client_secret
  ##~ op.parameters.add @parameter_authentication_provider_site
  ##~ op.parameters.add @parameter_authentication_provider_skip_ssl_certificate_verification
  ##~ op.parameters.add @parameter_authentication_provider_published
  #
  def update
    authorize_changes
    authentication_provider.update_attributes(authentication_provider_update_params)
    respond_with authentication_provider_presenter
  end

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account/authentication_providers.xml"
  ##~ e.responseClass = "List[authentication_provider]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Authentication Providers Admin Portal List"
  ##~ op.description = "Returns the list of all the authentication providers for the admin portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    presenters = ProviderOauthFlowPresenter.wrap(self_authentication_providers, request, request.host)
    respond_with(presenters)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/account/authentication_providers/{id}.xml"
  ##~ e.responseClass = "authentication_provider"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Authentication Provider Admin Portal Read"
  ##~ op.description = "Read an authentication provider for the admin portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_authentication_provider_id_by_id
  #
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
    ProviderOauthFlowPresenter.new(authentication_provider, request, request.host)
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
