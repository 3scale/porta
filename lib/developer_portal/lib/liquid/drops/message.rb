module Liquid
  module Drops
    # Wraps either Message (for outbox) or MessageRecipient (for inbox).
    class Message < Drops::Model

      allowed_name :message, :messages, :reply

      desc "Returns the ID of the message."
      def id
        @model.id
      end

      desc "If subject is not present then either a truncated body or `(no subject)` string is returned."
      def subject
        @model.subject.presence || @model.body.truncate(15).presence || '(no subject)'
      end

      desc "Returns body of the message."
      def body
        @model.body
      end

      desc "Returns the creation date."
      example %{
       {{ message.created_at | date: i18n.short_date }}
      }
      def created_at
        @model.created_at
      end

      desc "URL of the message detail, points either to inbox or outbox."
      def url
        if @model.hidden_at.present?
          admin_messages_trash_path(@model.id)
        else
          if @model.is_a?(MessageRecipient)
            admin_messages_inbox_path(@model.id)
          else
            admin_messages_outbox_path(@model.id)
          end
        end
      end

      desc "Either 'read' or 'unread'."
      def state
        @model.state
      end

      desc "Returns the name of the sender."
      def sender
        @model.sender.try(:name)
      end

      desc "Returns the name of the receiver."
      def to
        @model.to.first.try(:org_name)
      end

      # TODO: "to" and "recipients" are the same?
      def recipients
        if @model.recipients.count > 1
          "Multiple Recipients"
        else
          h(@model.recipients.first.try(:receiver).try(:org_name)) || ''
        end.html_safe
      end
    end
  end
end
