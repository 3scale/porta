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

    # This class is a compatibility layer added in https://github.com/3scale/porta/pull/1211
    # to make the legacy code work after BackendApis ("API as a Product" feature) were introduced.
    # For example, code like `proxy.update(api_backend: "value")` still works, even though `api_backend` is
    # now a field of BackendApi (aka `private_endpoint`), and not Proxy's.
    # It is achieved by building a BackendApi and a BackendApiConfig objects lazily .
    class BackendApiProxy
      attr_reader :service
      delegate :account, :backend_apis, :backend_api_configs, to: :service
      delegate :name, :system_name, to: :service, prefix: true

      def initialize(service)
        @service = service
      end

      def backend_api_config
        @backend_api_config ||= backend_api_configs.first ||
                                backend_api_configs.build(path: '/', backend_api: backend_api)
      end

      # Lazy building is required for some old code to work.
      # However, it is needed to be dissociated, because otherwise `provider.backend_apis` will include this object,
      # and validation will fail, because the lazily built BackendApi object itself might not be valid (due to a missing
      # `backend_endpoint`).
      def backend_api
        # Return early if we already have a persisted backend_api
        return @backend_api if @backend_api&.persisted?

        # Try to get backend_api from backend_api_configs, or keep the memoized unpersisted one, or build a new one
        @backend_api = backend_api_configs.first&.backend_api || @backend_api || build_dissociated_backend_api
      end

      def update!(attrs = {})
        BackendApi.transaction do
          backend_api.private_endpoint = attrs[:private_endpoint] if attrs.key?(:private_endpoint)
          backend_api.save!

          backend_api_config.path = attrs[:path] if attrs.key?(:path)
          backend_api_config.backend_api = backend_api
          backend_api_config.save!
        end
      end

      def update(attrs = {})
        update!(attrs)
      rescue ActiveRecord::RecordInvalid
        false
      end

      private

      # Build a BackendApi without adding it to `backend_apis` association to avoid polluting it with unpersisted records.
      def build_dissociated_backend_api
        BackendApi.new(
          account: account,
          system_name: service_system_name,
          name: "#{service_name} Backend",
          description: "Backend of #{service_name}"
        )
      end
    end

    def backend_api_proxy
      @backend_api_proxy ||= BackendApiProxy.new(self)
    end
  end
end
