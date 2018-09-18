module Liquid
  module Forms
    class Create < Forms::Base
      def http_method
        :post
      end
    end
  end
end
