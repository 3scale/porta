module Liquid
  module Forms
    class Update < Forms::Base
      delegate :id, to: :object, allow_nil: true

      def http_method
        :put
      end
    end
  end
end
