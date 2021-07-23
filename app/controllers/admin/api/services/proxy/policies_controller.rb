# frozen_string_literal: true

class Admin::Api::Services::Proxy::PoliciesController < Admin::Api::Services::BaseController
  wrap_parameters ::Proxy
  representer Proxy::PoliciesConfig

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/policies.json"
  ##~ e.responseClass = "json"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Proxy Policies Chain Show"
  ##~ op.description = "Returns a Proxy Policies Chain."
  ##~ op.group       = "proxy_policy"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def show
    respond_with(proxy.policies_config, represent_on_error: :resource)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/policies.json"
  ##~ e.responseClass = "json"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "Proxy Policies Chain Update"
  ##~ op.description = "Updates a Proxy Policies Chain."
  ##~ op.group       = "proxy_policy"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "policies_config", description: "Proxy policies chain", dataType: "string", paramType: "query", required: true
  #
  def update
    if proxy.update_attributes(proxy_params) && proxy.apicast_configuration_driven
      ApicastV2DeploymentService.new(@proxy).call(environment: :sandbox)
    end

    respond_with(proxy.policies_config, represent_on_error: :resource)
  end

  private

  def proxy_params
    proxy_params = params.require(:proxy).dup

    proxy_params.permit(:policies_config).tap do |whitelisted|
      whitelisted[:policies_config] = PoliciesConfigParams.new(proxy_params[:policies_config]).call
    end
  end

  def proxy
    @proxy ||= service.proxy
  end
end
