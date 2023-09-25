# frozen_string_literal: true
module Liquid
  module Drops
    class ApiSpec < Drops::Model
      def initialize(spec)
        @spec = spec
      end

      desc 'Returns the url of the API spec.'
      def url
        System::UrlHelpers.cms_url_helpers.swagger_spec_path(system_name, format: :json)
      end

      desc 'Returns the name of the spec.'
      def system_name
        @spec.system_name
      end

      desc 'Returns `true` if the API spec is published ("visible"), and `false` otherwise ("hidden")'
      def published?
        @spec.published
      end

      desc 'Returns the service of the spec if it has any or `nil` otherwise.'
      def service
        return unless (service = @spec.service)
        Drops::Service.new(service)
      end

      desc 'Returns the production public base URL of the service (API product) of the spec if it has any or `nil` otherwise'
      delegate :api_product_production_public_base_url, to: :@spec
    end
  end
end
