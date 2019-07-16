# frozen_string_literal: true

module BackendApiLogic
  module ServiceExtension
    extend ActiveSupport::Concern

    included do
      has_many :backend_api_configs, inverse_of: :service, dependent: :destroy
      has_many :backend_apis, through: :backend_api_configs, dependent: :destroy

      alias_method :backend_api, :first_backend_api
    end

    def first_backend_api
      @backend_api ||= find_or_create_first_backend_api!
    end

    def find_or_create_first_backend_api!
      return unless proxy && account
      config = backend_api_configs.first || create_first_backend_api_config!
      config.backend_api
    end

    private

    def create_first_backend_api_config!
      return unless proxy && account
      backend_api = account.backend_apis.create!(
        system_name: system_name,
        name: "#{name} Backend API",
        description: "Backend API of #{name}",
        private_endpoint: proxy['api_backend'].presence
      )
      backend_api_configs.create!(backend_api: backend_api, path: '')
    end
  end
end