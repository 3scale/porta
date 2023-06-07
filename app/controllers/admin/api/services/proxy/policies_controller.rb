# frozen_string_literal: true

class Admin::Api::Services::Proxy::PoliciesController < Admin::Api::Services::BaseController
  wrap_parameters ::Proxy
  representer Proxy::PoliciesConfig

  # Proxy Policies Chain Show
  # GET /admin/api/services/{service_id}/proxy/policies.json
  def show
    respond_with(proxy.policies_config, represent_on_error: :resource)
  end

  # Proxy Policies Chain Update
  # PUT /admin/api/services/{service_id}/proxy/policies.json
  def update
    if proxy.update(proxy_params) && proxy.apicast_configuration_driven
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
