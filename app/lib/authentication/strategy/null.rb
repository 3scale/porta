module Authentication
  module Strategy
    class Null < Base

      def initialize(*); end

      def authenticate(*)
        false
      end
    end
  end
end
