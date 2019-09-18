# frozen_string_literal: true

class ServiceCreator
  def initialize(service:, backend_api: nil)
    @service     = service
    @backend_api = backend_api
  end

  def call!(params = {})
    @service.transaction do
      backend_api_proxy_params = params.dup
      service_params = backend_api_proxy_params.slice!(:path, :private_endpoint)
      @service.attributes = service_params
      @service.save!
      if @backend_api
        save_assigned_backend_api(backend_api_proxy_params)
      else
        save_default_backend_api(backend_api_proxy_params)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    false
  end

  private

  def save_default_backend_api(params)
    if @service.account.provider_can_use?(:api_as_product)
      return true if [:path, :private_endpoint].none?{ |k| params.key?(k) }
      @service.backend_api_proxy.update!(params)
    else
      @service.backend_api_proxy.update!(private_endpoint: BackendApi.default_api_backend)
    end
  end

  def save_assigned_backend_api(attrs)
    config = @service.backend_api_configs.find_by(backend_api_id: @backend_api.id) ||
      @service.backend_api_configs.build(backend_api: @backend_api)
    config.path = path.to_s if attrs.key?(:path)
    config.save!
  end
end
