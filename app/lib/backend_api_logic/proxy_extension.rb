# frozen_string_literal: true

module BackendApiLogic
  module ProxyExtension
    extend ActiveSupport::Concern

    included do
      delegate :backend_api, to: :service, allow_nil: true
      delegate :private_endpoint, :private_endpoint=, to: :backend_api, allow_nil: true, prefix: true
      delegate :default_api_backend, to: 'BackendApi'

      alias_method :api_backend, :backend_api_private_endpoint

      validates :backend_api, nested_association: {report: {private_endpoint: :api_backend}}, associated: true
      before_save :save_backend_api

      has_many :backend_api_configs, through: :service
      accepts_nested_attributes_for :backend_api_configs
    end

    def api_backend=(endpoint)
      build_default_backend_api(endpoint)
      self.backend_api_private_endpoint = endpoint
    end

    protected

    def build_default_backend_api(endpoint)
      service.build_default_backend_api_config(endpoint) unless backend_api
    end

    def save_backend_api
      backend_api&.save
    end
  end
end
