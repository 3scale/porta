# frozen_string_literal: true

class Admin::Api::Services::ProxiesController < Admin::Api::Services::BaseController

  represents :json, entity: ::ProxyRepresenter::JSON
  represents :xml, entity: ::ProxyRepresenter::XML

  wrap_parameters ::Proxy, include: Proxy.user_attribute_names

  # Proxy Read
  # GET /admin/api/services/{service_id}/proxy.xml
  def show
    respond_with(proxy)
  end

  # Proxy Update
  # PATCH /admin/api/services/{service_id}/proxy.xml
  def update
    ProxyDeploymentService.call(proxy) if proxy.update(proxy_params)

    respond_with(proxy)
  end

  # Proxy Deploy
  # POST /admin/api/services/{service_id}/proxy/deploy.xml
  def deploy
    ProxyDeploymentService.call(proxy)

    respond_with(proxy)
  end

  private

  def proxy_params
    permitted_params = %i[endpoint api_backend credentials_location auth_app_key
                          auth_app_id auth_user_key sandbox_endpoint error_auth_failed error_auth_missing
                          error_status_auth_failed error_status_auth_failed error_headers_auth_failed
                          error_status_auth_missing error_headers_auth_missing error_no_match
                          error_status_no_match error_headers_no_match secret_token hostname_rewrite
                          oauth_login_url api_test_path oidc_issuer_endpoint oidc_issuer_type error_status_limits_exceeded
                          error_headers_limits_exceeded error_limits_exceeded]
    permitted_params += GatewayConfiguration::ATTRIBUTES

    params.require(:proxy).permit(permitted_params)
  end

  def proxy
    @_proxy ||= service.proxy
  end
end
