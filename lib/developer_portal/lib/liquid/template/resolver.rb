module Liquid
  class Template
    class Resolver < ActionView::Resolver
      # really nasty way, but how else ?
      attr_accessor :cms

      def self.config
        Rails.configuration.liquid
      end

      def self.instance(scope)
        config.resolver_caching ? cached(scope) : new(scope)
      end

      @@cache = {}
      def self.cached(scope)
        @@cache[scope.id] ||= new(scope)
      end

      def initialize(scope)
        @scope = scope
        super()
      end

      def _find_all(name, prefix, partial, details, key = nil, locals = [])
        path = Path.build(name, prefix, partial)

        @scope.templates.for_rails_view(path).map do |record|
          Liquid::Template::View.from(record, path, cms)
        end
      end
    end
  end
end
