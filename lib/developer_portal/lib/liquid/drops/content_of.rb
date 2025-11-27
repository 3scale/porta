module Liquid
  module Drops
    class ContentOf < Drops::Base

      allowed_name :content_of

      def liquid_method_missing(name)
        content_for[name]
      end

      private

      def content_for
        @context.registers.fetch(:content_for)
      end

    end
  end
end
