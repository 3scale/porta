# frozen_string_literal: true

module BackendApiLogic
  module ProxyExtension
    extend ActiveSupport::Concern

    included do
      delegate :api_backend, :api_backend=, :backend_api, :backend_api_proxy, to: :service
      delegate :private_endpoint, :private_endpoint=, to: :backend_api, prefix: true
      delegate :default_api_backend, to: 'BackendApi'

      before_save :save_backend_api

      has_many :backend_api_configs, through: :service
      accepts_nested_attributes_for :backend_api_configs

      validates :backend_api, nested_association: {report: {private_endpoint: :api_backend}}, associated: true, if: :validate_backend_api?
    end

    def api_backend_present?
      api_backend
    end

    protected

    def validate_backend_api?
      backend_api.private_endpoint_changed?
    end

    def save_backend_api
      backend_api_private_endpoint && backend_api_proxy.update!(private_endpoint: backend_api_private_endpoint)
    end
  end
end
