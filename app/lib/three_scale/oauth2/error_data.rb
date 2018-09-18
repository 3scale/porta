module ThreeScale
  module OAuth2
    class ErrorData
      attr_reader :error

      def initialize(error: )
        @error = error
      end

      def to_hash
        {}
      end

      def [](_)
      end
    end
  end
end
