module CMS
  class Handler
    class Nothing < Base
      def convert(markup)
        markup # no need to convert anything
      end
    end
  end
end
