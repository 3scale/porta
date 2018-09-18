module Liquid
  class Template
    class WithoutLiquidResolver < ActionView::OptimizedFileSystemResolver

      def initialize(path = Rails.root.join('app', 'views'))
        super
      end

      def build_query(path, details)
        # remove liquid from allowed handlers
        details = details.merge(handlers: details[:handlers] - [:liquid])
        super #(path, details)
      end
    end
  end
end
