# frozen_string_literal: true

require 'addressable/template'

module ThreeScale
  module OpenApi
    class UrlResolver
      def initialize(specification)
        @specification = specification
      end

      def servers
        @specification.fetch('servers', []).map do |server|
          url = server['url']
          variables = server['variables']
          variables.present? ? resolve_servers_from_variables(url, variables) : url
        end.flatten
      end

      # By default, the variable values are URL-encoded. The purpose of this processor is 
      # to skip URL-encoding, so that URL can be used in the variable, e.g.
      #   "servers": [
      #     {
      #       "url": "{apiRoot}/echo/v1",
      #       "variables": {
      #         "apiRoot": {
      #           "default": "https://echo-api.3scale.net"
      #         }
      #       }
      #     }
      #   ],
      class SkipURLEncodingProcessor
        def self.transform(name, value)
          return value
        end
      end

      def self.resolve_servers_from_variables(server_url, variables = {})
        variable_names = variables.keys
        variable_values = variables.values.map { |variable| variable['enum'] || [variable['default']] }
        value_combinations = variable_values.reduce(&:product).map(&Array.method(:wrap)).map { |values| variable_names.zip(values).to_h }
        value_combinations.map { |values| Addressable::Template.new(server_url).expand(values, SkipURLEncodingProcessor).to_s }
      end

      delegate :resolve_servers_from_variables, to: 'self.class'
    end
  end
end
