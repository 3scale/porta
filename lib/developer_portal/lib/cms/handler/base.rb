module CMS
  class Handler
    class Base < SimpleDelegator

      def render(*)
        convert super
      end

      def render!(*)
        convert super
      end

      def convert(markup)
        # implement this method in subclasses
      end
    end
  end
end
