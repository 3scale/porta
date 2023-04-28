# frozen_string_literal: true

class Admin::Api::Services::Proxy::OIDCConfigurationsController < Admin::Api::Services::BaseController

  representer ::OIDCConfiguration
  wrap_parameters name: :oidc_configuration, include: OIDCConfiguration::Config::ATTRIBUTES
  self.access_token_scopes = :account_management

  # OIDC Configuration Show
  # GET /admin/api/services/{service_id}/proxy/oidc_configuration.xml
  def show
    respond_with(configuration)
  end

  # OIDC Configuration Update
  # PATCH /admin/api/services/{service_id}/proxy/oidc_configuration.xml
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
