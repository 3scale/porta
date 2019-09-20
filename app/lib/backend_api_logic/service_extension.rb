# frozen_string_literal: true

module BackendApiLogic
  module ServiceExtension
    extend ActiveSupport::Concern

    included do
      has_many :backend_api_configs, inverse_of: :service, dependent: :destroy
      has_many :backend_apis, through: :backend_api_configs

      delegate :backend_api, to: :backend_api_proxy
      delegate :api_backend, :api_backend=, to: :backend_api

      has_many :backend_api_metrics, through: :backend_api_configs

      has_many :all_metrics, ->(object) do
        unscope(:where).where('(owner_type = ? AND owner_id = ?) OR (owner_type = ? AND owner_id IN (?))', 'Service', object.id, 'BackendApi', object.backend_apis.pluck(:id))
      end, class_name: 'Metric'
    end

    # TODO: This is used by db/migrate/20190716110520_create_the_backend_apis_of_services.rb
    # We should Remove this after 2.7 is released
    # https://issues.jboss.org/browse/THREESCALE-3517
    def first_backend_api
      @backend_api ||= find_or_create_first_backend_api!
    end

    def find_or_create_first_backend_api!
      return unless account
      config = backend_api_configs.first || create_first_backend_api_config!
      config.backend_api
    end

    def create_first_backend_api_config!
      backend_api = account.backend_apis.build(
        system_name: system_name,
        name: "#{name} Backend API",
        description: "Backend API of #{name}",
        private_endpoint: proxy&.[]('api_backend')
      )
      constructor = new_record? ? :build : :create!
      attrs = {backend_api: backend_api, path: ''}
      backend_api_configs.public_send(constructor, attrs)
    end

    class BackendApiProxy
      attr_reader :service
      delegate :account, :backend_apis, :backend_api_configs, to: :service
      delegate :name, :system_name, to: :service, prefix: true

      def initialize(service)
        @service = service
      end

      def backend_api_config
        @backend_api_config ||= backend_api_configs.first ||
                                backend_api_configs.build(path: '', backend_api: backend_api)
      end

      def backend_api
        @backend_api ||= backend_api_configs.first&.backend_api || account.backend_apis.build(system_name: service_system_name, name: "#{service_name} Backend API", description: "Backend API of #{service_name}")
      end

      def update!(attrs = {})
        BackendApi.transaction do
          backend_api_config.path = attrs[:path] if attrs.key?(:path)
          backend_api_config.backend_api = backend_api
          backend_api.private_endpoint = attrs[:private_endpoint] if attrs.key?(:private_endpoint)
          backend_api.save!
          backend_api_config.save!
        end
      end

      def update(attrs = {})
        update!(attrs)
      rescue ActiveRecord::RecordInvalid
        false
      end
    end

    def backend_api_proxy
      @backend_api_proxy ||= BackendApiProxy.new(self)
    end
  end
end
