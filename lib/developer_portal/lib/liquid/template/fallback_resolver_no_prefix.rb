# frozen_string_literal: true

module Liquid
  class Template
    class FallbackResolverNoPrefix < FallbackResolver

      def initialize(path = DeveloperPortal::VIEW_PATH)
        super
      end

      def find_templates(name, prefix, partial, details, outside_app_allowed = false)
        path = build_path(name, prefix = nil, partial)

        # force just liquid format
        details = details.merge(handlers: [:liquid])

        query(path, details, details[:formats], outside_app_allowed)
      end

    end
  end
end
