module Authentication
  module Strategy

    # Dummy auth strategy that always rejects the login.
    # Used when no other strategy is applicable, to prevent an error 500
    class Null < Base

      def initialize(*); end

      def authenticate(*)
        false
      end
    end
  end
end
