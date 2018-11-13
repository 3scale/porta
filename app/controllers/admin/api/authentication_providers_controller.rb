# frozen_string_literal: true

class Admin::Api::AuthenticationProvidersController < Admin::Api::BaseController
  wrap_parameters :authentication_provider
  represents :json, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::JSON
  represents :xml, entity: ::AuthenticationProviderRepresenter, collection: ::AuthenticationProvidersRepresenter::XML

  before_action :find_authentication_provider, only: %i[update show]
  before_action :authorize_authentication_provider, only: %i[update show]

  ##~ @parameter_authentication_provider_id_by_id = {:name => "id", :description => "ID of the authentication provider.", :dataType => "string", :required => true, :paramType => "path"}
  ##~ @parameter_authentication_provider_dev_kind_required = {:name => "kind", :description => "The kind of authentication provider which can be either 'github', 'auth0', 'keycloak' or a custom one. Use 'keycloak' for Red Hat Single Sign-On.", :dataType => "string", :required => true, :paramType => "query"}
  ##~ @parameter_authentication_provider_name = {:name => "name", :description => "Name of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_system_name = {:name => "system_name", :description => "System Name of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_client_id = {:name => "client_id", :description => "Client ID of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_client_secret = {:name => "client_secret", :description => "Client Secret of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_site = {:name => "site", :description => "Site o Realm of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_token_url = {:name => "token_url", :description => "Token URL of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_user_info_url = {:name => "user_info_url", :description => "User info URL of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_authorize_url = {:name => "authorize_url", :description => "Authorize URL of the authentication provider.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_identifier_key = {:name => "identifier_key", :description => "Identifier key. 'id' by default.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_username_key = {:name => "username_key", :description => "Username key. 'login' by default.", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_trust_email = {:name => "trust_email", :description => "Trust emails automatically. False by default", :dataType => "boolean", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_published = {:name => "published", :description => "Published authentication provider. False by default", :dataType => "boolean", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_branding_state_event = {:name => "branding_state_event", :description => "Branding state event of the authentication provider. Only available for Github. It can be either 'brand_as_threescale' (the default one) or 'custom_brand'", :dataType => "string", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_skip_ssl_certificate_verification = {:name => "skip_ssl_certificate_verification", :description => "Skip SSL certificate verification. False by default.", :dataType => "boolean", :required => false, :paramType => "query"}
  ##~ @parameter_authentication_provider_automatically_approve_accounts = {:name => "automatically_approve_accounts", :description => "Automatically approve accounts. False by default.", :dataType => "boolean", :required => false, :paramType => "query"}

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/authentication_providers.xml"
  ##~ e.responseClass = "authentication_provider"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Authentication Provider Developer Portal Create"
  ##~ op.description = "Creates an authentication provider for the developer portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_authentication_provider_dev_kind_required
  ##~ op.parameters.add @parameter_authentication_provider_name
  ##~ op.parameters.add @parameter_authentication_provider_system_name
  ##~ op.parameters.add @parameter_authentication_provider_client_id
  ##~ op.parameters.add @parameter_authentication_provider_client_secret
  ##~ op.parameters.add @parameter_authentication_provider_site
  ##~ op.parameters.add @parameter_authentication_provider_token_url
  ##~ op.parameters.add @parameter_authentication_provider_user_info_url
  ##~ op.parameters.add @parameter_authentication_provider_authorize_url
  ##~ op.parameters.add @parameter_authentication_provider_identifier_key
  ##~ op.parameters.add @parameter_authentication_provider_username_key
  ##~ op.parameters.add @parameter_authentication_provider_trust_email
  ##~ op.parameters.add @parameter_authentication_provider_published
  ##~ op.parameters.add @parameter_authentication_provider_branding_state_event
  ##~ op.parameters.add @parameter_authentication_provider_skip_ssl_certificate_verification
  ##~ op.parameters.add @parameter_authentication_provider_automatically_approve_accounts
  #
  def create
    build_authentication_provider
    authorize_authentication_provider
    authentication_provider.save
    respond_with authentication_provider_presenter
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/authentication_providers/{id}.xml"
  ##~ e.responseClass = "authentication_provider"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Authentication Provider Developer Portal Update"
  ##~ op.description = "Updates an authentication provider for the developer portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_authentication_provider_id_by_id
  ##~ op.parameters.add @parameter_authentication_provider_client_id
  ##~ op.parameters.add @parameter_authentication_provider_client_secret
  ##~ op.parameters.add @parameter_authentication_provider_site
  ##~ op.parameters.add @parameter_authentication_provider_published
  ##~ op.parameters.add @parameter_authentication_provider_skip_ssl_certificate_verification
  ##~ op.parameters.add @parameter_authentication_provider_automatically_approve_accounts
  #
  def update
    authentication_provider.update_attributes(authentication_provider_update_params)
    respond_with authentication_provider_presenter
  end

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/authentication_providers.xml"
  ##~ e.responseClass = "List[authentication_provider]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Authentication Providers Developer Portal List"
  ##~ op.description = "Returns the list of all the authentication providers for the developer portal."
  ##~ op.group = "authentication_provider"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    presenters = OauthFlowPresenter.wrap(authentication_providers, request)
    respond_with(presenters)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/authentication_providers/{id}.xml"
  ##~ e.responseClass = "authentication_provider"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Authentication Provider Read"
  ##~ op.description = "Returns an authentication provider."
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
    @authentication_provider = authentication_providers.build_kind(kind: attributes.require(:kind), **attributes.symbolize_keys)
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
