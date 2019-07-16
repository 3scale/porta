# frozen_string_literal: true

module BackendApiLogic
  module ProxyExtension
    extend ActiveSupport::Concern

    included do
      delegate :backend_api, to: :service
      delegate :private_endpoint, :private_endpoint=, to: :backend_api, allow_nil: true, prefix: true

      alias_method :api_backend, :backend_api_private_endpoint
      alias_method :api_backend=, :backend_api_private_endpoint=

      validates :backend_api, nested_association: {report: {private_endpoint: :api_backend}}, associated: true
      before_save :save_backend_api
    end

    protected

    def save_backend_api
      backend_api.save
    end
  end
end
