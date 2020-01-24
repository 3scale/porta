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
          variables ? resolve_servers_from_variables(url, variables) : url
        end.flatten
      end

      def self.resolve_servers_from_variables(server_url, variables = {})
        variable_names = variables.keys
        variable_values = variables.values.map { |variable| variable['enum'] || [variable['default']] }
        value_combinations = variable_values.reduce(&:product).map(&Array.method(:wrap)).map { |values| variable_names.zip(values).to_h }
        value_combinations.map { |values| Addressable::Template.new(server_url).expand(values).to_s }
      end

      delegate :resolve_servers_from_variables, to: 'self.class'
    end
  end
end
