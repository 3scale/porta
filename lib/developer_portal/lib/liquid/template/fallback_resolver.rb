module Liquid
  class Template
    class FallbackResolver < ActionView::FileSystemResolver

      def initialize(path = DeveloperPortal::VIEW_PATH)
        super
      end

      def find_templates(name, prefix, partial, details, outside_app_allowed)
        path = build_path(name, prefix, partial)

        # force just liquid format
        details = details.merge(handlers: [:liquid])

        query(path, details, details[:formats], outside_app_allowed)
      end

      def build_path(name, prefix, partial)
        prefix = prefix ? [prefix] : []
        prefix = ::File.join(*prefix)
        ::Rails.logger.debug { "FallbackResolver: path: #{[name, prefix, partial].inspect}" }
        super
      end

      public :find_templates
    end

    class FallbackResolverNoPrefix < FallbackResolver

      def initialize(path = DeveloperPortal::VIEW_PATH)
        super
      end

      def find_templates(name, prefix, partial, details, outside_app_allowed)
        path = build_path(name, prefix = nil, partial)

        # force just liquid format
        details = details.merge(handlers: [:liquid])

        query(path, details, details[:formats], outside_app_allowed)
      end

    end

  end
end
