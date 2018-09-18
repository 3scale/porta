module Liquid
  module Forms
    module Message
      class Reply < Forms::Create
        def html_class_name
          'message reply'
        end

        def form_options
          super.merge(id: 'message-form')
        end

        def path
          admin_messages_inbox_index_path()
        end
      end

      class Create < Forms::Create

        def html_class_name
          'message'
        end

        def path
          admin_messages_outbox_index_path
        end

        def form_options
          super.merge(id: 'message-form')
        end
      end
    end
  end
end
