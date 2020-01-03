# frozen_string_literal: true

class ServiceCreator

  delegate :backend_api_configs, :backend_api_proxy, :account, :proxy, to: :@service
  delegate :provider_can_use?, to: :account

  def initialize(service:, backend_api: nil)
    @service     = service
    @backend_api = backend_api
  end

  def call!(params = {})
    @service.transaction do
      backend_api_proxy_params = params.dup
      service_params = backend_api_proxy_params.slice!(:path, :private_endpoint)
      @service.attributes = service_params
      save!(backend_api_proxy_params)
    end
  end

  def call(params = {})
    call!(params)
  rescue ActiveRecord::RecordInvalid
    if proxy && proxy.errors[:endpoint].any? { |message| message =~ /the accepted format is/ }
      @service.errors.add(:system_name, :invalid_for_proxy_endpoints)
    end

    false
  end

  private

  def save!(params)
    @service.save!
    if @backend_api
      save_assigned_backend_api(params)
    else
      save_default_backend_api(params)
    end
  end

  def save_default_backend_api(params)
    if provider_can_use?(:api_as_product)
      return true if %i[path private_endpoint].none? { |key| params.key?(key) }
      backend_api_proxy.update!(params)
    else
      backend_api_proxy.update!(private_endpoint: BackendApi.default_api_backend)
    end
  end

  def save_assigned_backend_api(attrs)
    config = backend_api_configs.find_by(backend_api_id: @backend_api.id) ||
             backend_api_configs.build(backend_api: @backend_api, path: '/')
    config.path = path.to_s if attrs.key?(:path)
    config.save!
  end
end
