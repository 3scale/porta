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

          next url unless variables

          variables.transform_values! { |variable| variable['enum'] || [variable['default']] }
          value_combinations = variables.values.reduce(&:product).map(&Array.method(:wrap))
          possible_values = value_combinations.map { |values| variables.keys.zip(values).to_h }
          possible_values.map { |values| Addressable::Template.new(url).expand(values).to_s }
        end.flatten
      end
    end
  end
end
