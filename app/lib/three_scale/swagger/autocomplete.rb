require 'hashie'

module ThreeScale
  module Swagger
    module Autocomplete
      def self.fix!(spec)
        return spec unless spec.respond_to?(:deep_dup)

        dup = spec.deep_dup.extend(Hashie::Extensions::DeepFind)
        (dup.deep_find_all('parameters') || []).flatten.each do |parameters|

          if parameters.present? && parameters['threescale_name'].present?

            parameters['x-data-threescale-name'] = parameters['threescale_name']
          end
        end

        dup
      end
    end
  end
end
