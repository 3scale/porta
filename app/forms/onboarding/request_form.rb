# frozen_string_literal: true

class Onboarding::RequestForm < Reform::Form
  include ThreeScale::Reform

  SLASH = '/'

  model :proxy

  property :path, from: :api_test_path
  property :api_base_url, from: :api_backend

  validates :path, format: { with: Proxy::URI_PATH_PART, allow_nil: true, allow_blank: true }

  def path=(value)
    super normalize_path(value)
  end

  def path_without_slash
    path.to_s.sub(/^\//, '')
  end

  def api_name
    model.service.name.truncate(20)
  end

  def api_base_url
    URI(base_url = super.to_s)
  rescue URI::InvalidURIError
    base_url
  end

  def proxy_base_url
    path = model.backend_api_configs.first&.path || ''
    base = model.sandbox_endpoint

    URI.join(base, path).to_s
  end

  def uri
    return unless model.api_backend
    base_url = api_base_url
    test_path = File.join(base_url.try(:path).to_s, path.to_s)
    URI.join(base_url, test_path).to_s
  end

  def proxy_auth_params
    model.authentication_params_for_proxy.to_query
  end

  def test_api!
    return unless ProxyDeploymentService.call(model)

    proxy_test_service = ProxyTestService.new(model)

    status = proxy_test_service.perform
  ensure
    model.update_column(:api_test_success, status&.success?)
  end

  protected

  def normalize_path(path)
    return unless path
    path.prepend(SLASH) unless path.start_with?(SLASH)
    path
  end
end
