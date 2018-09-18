# frozen_string_literal: true

class Admin::Api::Services::Proxy::PoliciesController < Admin::Api::Services::BaseController

  wrap_parameters ::Proxy
  representer Proxy::PoliciesConfig

  before_action :authorize_rolling_update

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
    policies_config = Proxy::PoliciesConfig.new(proxy.policies_config)
    respond_with(policies_config, represent_on_error: :resource)
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
    if proxy.update_attributes(proxy_params)
      proxy.deploy_v2 if proxy.apicast_configuration_driven
    end

    policies_config = Proxy::PoliciesConfig.new(proxy.policies_config)
    policies_config.valid? # Needed to set errors if any
    respond_with(policies_config, represent_on_error: :resource)
  end

  private

  def authorize_rolling_update
    provider_can_use!(:policies)
  end

  def proxy_params
    params.require(:proxy).permit(:policies_config).tap do |whitelisted|
      whitelisted[:policies_config] = params[:proxy][:policies_config]
    end
  end

  def proxy
    @proxy ||= service.proxy
  end
end
