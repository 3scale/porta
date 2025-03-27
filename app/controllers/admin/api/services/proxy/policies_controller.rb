# frozen_string_literal: true

class Admin::Api::Services::Proxy::PoliciesController < Admin::Api::Services::BaseController
  wrap_parameters ::Proxy
  representer Proxy::PoliciesConfig

  self.access_token_scopes = %i[policy_registry account_management]

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

    respond_with(proxy.policies_config, represent_on_error: represent_on_error)
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

  # Either to show policy-level errors (e.g. one policy lacks a field) or chain-level errors (e.g. chain is too long)
  # Returns +:resource+ to show policy errors, +nil+ for chain errors.
  def represent_on_error
    :resource if proxy.errors.messages[:policies_config] == [I18n.t(:invalid_policy, scope: 'activemodel.errors.models.policies_config.attributes.policies_config')]
  end
end
