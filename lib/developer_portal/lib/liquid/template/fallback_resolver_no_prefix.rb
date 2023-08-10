# frozen_string_literal: true

module Liquid
  class Template
    class FallbackResolverNoPrefix < FallbackResolver

      def initialize(path = DeveloperPortal::VIEW_PATH)
        super
      end

      def _find_all(name, prefix, partial, details, key = nil, locals = [])
        path = build_path(name, prefix = nil, partial)

        # force just liquid format
        details = details.merge(handlers: [:liquid])

        query(path, details, details[:formats], locals, cache: !!key)
      end
    end
  end
end
