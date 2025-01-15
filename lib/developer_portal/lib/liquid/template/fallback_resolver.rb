# frozen_string_literal: true

module Liquid
  class Template
    class FallbackResolver < ActionView::FileSystemResolver
      def initialize(path = DeveloperPortal::VIEW_PATH)
        super
      end

      def _find_all(name, prefix, partial, details, key = nil, locals = [])
        # force just liquid format
        super(name, prefix, partial, details.merge(handlers: [:liquid]), key, locals)
      end

      public :_find_all
    end
  end
end
