require 'hashie'

module ThreeScale
  module Swagger
    module Schemes
      def self.fix!(spec)
        return spec unless spec.respond_to?(:deep_dup)
        return spec if spec["schemes"].present?

        dup = spec.deep_dup.extend(Hashie::Extensions::DeepFind)

        scheme = dup.fetch('basePath', '').split("://")[0]
        unless ["http", "https"].include?(scheme)
          scheme = "http"
        end

        dup["schemes"] = [scheme]

        dup
      end
    end
  end
end
