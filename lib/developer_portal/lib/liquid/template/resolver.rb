module Liquid
  class Template
    class Resolver < ActionView::Resolver
      # really nasty way, but how else ?
      attr_accessor :cms

      @instances = Concurrent::Map.new

      class << self
        def config
          Rails.configuration.liquid
        end

        def instance(scope)
          config.resolver_caching ? cached(scope) : new(scope)
        end

        def cached(scope)
          @instances[scope.id] ||= new(scope)
        end
      end

      def initialize(scope)
        @scope = scope
        super()
      end

      def _find_all(name, prefix, partial, details, key = nil, locals = [])
        path = ActionView::TemplatePath.build(name, prefix, partial)

        @scope.templates.for_rails_view(path).map do |record|
          Liquid::Template::View.from(record, path, cms)
        end
      end
    end
  end
end
