# frozen_string_literal: true

module BackendApiLogic
  module ServiceExtension
    extend ActiveSupport::Concern

    included do
      has_many :backend_api_configs, inverse_of: :service, dependent: :destroy
      has_many :backend_apis, through: :backend_api_configs

      delegate :backend_api, to: :backend_api_proxy
      delegate :api_backend, to: :backend_api
      delegate :api_backend=, to: :backend_api

      has_many :backend_api_metrics, through: :backend_api_configs

      has_many :all_metrics, ->(object) do
        unscope(:where).where('(owner_type = ? AND owner_id = ?) OR (owner_type = ? AND owner_id IN (?))', 'Service', object.id, 'BackendApi', object.backend_apis.pluck(:id))
      end, class_name: 'Metric'
    end

    class BackendApiProxy
      attr_reader :service
      delegate :account, :backend_apis, :backend_api_configs, to: :service

      def initialize(service)
        @service = service
      end

      def backend_api_config
        @backend_api_config ||= backend_api.backend_api_configs.first ||
                                backend_api_configs.build(path: '', backend_api: backend_api)
      end

      def backend_api
        return unless account
        @backend_api ||= backend_api_configs.first&.backend_api || account.backend_apis.build(name: service.system_name, name: "#{service.name} Backend API", description: "Backend API of #{service.name}")
      end

      def update!(attrs = {})
        BackendApi.transaction do
          backend_api_config.path = attrs[:path] if attrs.key?(:path)
          backend_api_config.backend_api = backend_api
          backend_api.private_endpoint = attrs[:private_endpoint] if attrs.key?(:private_endpoint)
          # binding.pry
          backend_api.save!
          backend_api_config.save!
        end
      end
    end

    def backend_api_proxy
      @backend_api_proxy ||= BackendApiProxy.new(self)
    end
  end
end
