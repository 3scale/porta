module Liquid
  module Forms
    class Login < Forms::Create

      def html_class_name
        'formtastic session'
      end

      def form_options
        super.merge(id: 'new_session')
      end

      def path
        session_path
      end
    end
  end
end
