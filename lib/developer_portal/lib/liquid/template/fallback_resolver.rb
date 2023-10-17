# frozen_string_literal: true

module Liquid
  class Template
    class FallbackResolver < ActionView::FileSystemResolver
      def initialize(path = DeveloperPortal::VIEW_PATH)
        super
      end

      def _find_all(name, prefix, partial, details, key = nil, locals = [])
        path = build_path(name, prefix, partial)

        # force just liquid format
        details = details.merge(handlers: [:liquid])

        query(path, details, details[:formats], locals, cache: !!key)
      end

      def build_path(name, prefix, partial)
        prefix = prefix ? [prefix] : []
        prefix = ::File.join(*prefix)
        ::Rails.logger.debug { "FallbackResolver: path: #{[name, prefix, partial].inspect}" }
        Path.build(name, prefix, partial)
      end

      public :_find_all
    end
  end
end
