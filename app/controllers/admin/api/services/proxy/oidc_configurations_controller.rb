# frozen_string_literal: true

class Admin::Api::Services::Proxy::OIDCConfigurationsController < Admin::Api::Services::BaseController
  ##~ sapi = source2swagger.namespace("Account Management API")

  representer ::OIDCConfiguration
  wrap_parameters name: :oidc_configuration, include: OIDCConfiguration::Config::ATTRIBUTES
  self.access_token_scopes = :account_management

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/oidc_configuration.xml"
  ##~ e.responseClass = "oidc_configuration"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "OIDC Configuration Show"
  ##~ op.description = "Get the Proxy OIDC configuration."
  ##~ op.group = "oidc_configuration"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  def show
    respond_with(configuration)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/oidc_configuration.xml"
  ##~ e.responseClass = "oidc_configuration"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PATCH"
  ##~ op.summary    = "OIDC Configuration Update"
  ##~ op.description = "Changes the Proxy OIDC configuration."
  ##~ op.group = "oidc_configuration"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "standard_flow_enabled", description: "Enable Authorization Code Flow (Standard Flow)", dataType: "boolean", paramType: "query", required: false
  ##~ op.parameters.add name: "implicit_flow_enabled", description: "Enable Implicit Flow", dataType: "boolean", paramType: "query", required: false
  ##~ op.parameters.add name: "service_accounts_enabled", description: "Enable Service Account Flow (Standard Flow)", dataType: "boolean", paramType: "query", required: false
  ##~ op.parameters.add name: "direct_access_grants_enabled", description: "Enable Direct Access Grant Flow", dataType: "boolean", paramType: "query", required: false
  def update
    configuration.update_attributes(oidc_configuration_params)
    respond_with(configuration)
  end

  protected

  def oidc_configuration_params
    params.require(:oidc_configuration).permit(*OIDCConfiguration::Config::ATTRIBUTES)
  end

  def configuration
    proxy.oidc_configuration
  end

  def proxy
    @_proxy ||= service.proxy
  end
end
