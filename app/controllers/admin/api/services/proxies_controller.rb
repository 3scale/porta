# frozen_string_literal: true

class Admin::Api::Services::ProxiesController < Admin::Api::Services::BaseController
  ##~ sapi = source2swagger.namespace("Account Management API")

  represents :json, entity: ::ProxyRepresenter::JSON
  represents :xml, entity: ::ProxyRepresenter::XML

  wrap_parameters ::Proxy

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy.xml"
  ##~ e.responseClass = "proxy"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Proxy Read"
  ##~ op.description = "Returns the Proxy of a Service."
  ##~ op.group = "proxy"
  #
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def show
    respond_with(proxy)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy.xml"
  ##~ e.responseClass = "proxy"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PATCH"
  ##~ op.summary    = "Proxy Update"
  ##~ op.description = "Changes the Proxy settings. This will create a new APIcast configuration version for the Staging environment with the updated settings."
  ##~ op.group = "proxy"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "endpoint", description: "Public Base URL for production environment.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "api_backend", description: "Private Base URL.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "credentials_location", description: "Credentials Location. Either headers, query or authorization for the Basic Authorization.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "auth_app_key", description: "Parameter/Header where App Key is expected.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "auth_app_id", description: "Parameter/Header where App ID is expected.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "auth_user_key", description: "Parameter/Header where User Key is expected.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "error_auth_failed", description: "Error message on failed authentication.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "error_status_auth_failed", description: "Status code on failed authentication.", dataType: "int", paramType: "query", required: false
  ##~ op.parameters.add name: "error_headers_auth_failed", description: "Content-Type header on failed authentication.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "error_auth_missing", description: "Error message on missing authentication.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "error_status_auth_missing", description: "Status code on missing authentication.", dataType: "int", paramType: "query", required: false
  ##~ op.parameters.add name: "error_headers_auth_missing", description: "Content-Type header on missing authentication.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "error_no_match", description: "Error message when no mapping rule is matched.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "error_status_no_match", description: "Status code when no mapping rule is matched.", dataType: "int", paramType: "query", required: false
  ##~ op.parameters.add name: "error_headers_no_match", description: "Content-Type header when no mapping rule is matched.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "oidc_issuer_endpoint", description: "Location of your OpenID Provider.", dataType: "string", paramType: "query", required: false
  ##~ op.parameters.add name: "sandbox_endpoint", description: "Sandbox endpoint.", dataType: "string", paramType: "query", required: false
  #
  def update
    if proxy.update_attributes(proxy_params)
      if proxy.service_mesh_integration?
        proxy.deploy!
      elsif proxy.apicast_configuration_driven
        proxy.deploy_v2
      end
    end

    respond_with(proxy)
  end

  private

  def proxy_params
    permitted_params = %i[endpoint api_backend credentials_location auth_app_key
                          auth_app_id auth_user_key sandbox_endpoint error_auth_failed error_auth_missing
                          error_status_auth_failed error_status_auth_failed error_headers_auth_failed
                          error_status_auth_missing error_headers_auth_missing error_no_match
                          error_status_no_match error_headers_no_match secret_token hostname_rewrite
                          oauth_login_url api_test_path oidc_issuer_endpoint]
    params.require(:proxy).permit(permitted_params)
  end

  def proxy
    @_proxy ||= service.proxy
  end
end
