module Liquid
  module Forms
    class Search < Forms::Base

      def form_options
        super.merge(id: 'searchAgain')
      end

      def http_method
         :get
      end

      def form_method
        :get
      end

      def path
        search_path
      end
    end
  end
end
