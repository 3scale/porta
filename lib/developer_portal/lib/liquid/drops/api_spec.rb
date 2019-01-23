# frozen_string_literal: true
module Liquid
  module Drops
    class ApiSpec < Drops::Model
      def initialize(spec)
        @spec = spec
      end

      desc 'Returns the url of the API spec.'
      def url
        cms_url_helpers.swagger_spec_path(system_name, format: :json)
      end

      desc 'Returns the name of the spec.'
      def system_name
        @spec.system_name
      end

      desc 'Returns the service of the spec if it has any or `nil` otherwise.'
      def service
        return unless (service = @spec.service)
        Drops::Service.new(service)
      end

      desc 'Returns the public production host endpoint if it linked to a service `nil` otherwise'
      def host_with_port
        @spec.host_with_port
      end
    end
  end
end
