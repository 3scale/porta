# frozen_string_literal: true

module Liquid
  class Template
    class FallbackResolverNoPrefix < FallbackResolver
      def _find_all(name, prefix, partial, details, key = nil, locals = [])
        # force just liquid format and set an empty prefix
        super(name, '', partial, details.merge(handlers: [:liquid]), key, locals)
      end
    end
  end
end
