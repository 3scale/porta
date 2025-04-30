module Authentication
  module Strategy
    class Null < Base
      def authenticate(*)
        false
      end
    end
  end
end
