# encoding: UTF-8

module Liquid
  module Drops
    class Invitation < Drops::Model
      allowed_name :invitation, :invitations

      drop_example %{
        <div> Email: {{ invitation.email }} </div>
        <div>

        <tr id="invitation_{{ invitation.id }}">
          <td> {{ invitation.email }} </td>
          <td> {{ invitation.sent_at | date: i18n.short_date }} </td>
          <td>
            {% if invitation.accepted? %}
              yes, on {{invitation.accepted_at | format: i18n.short_date }}
            {% else %}
              no
            {% endif %}
          </td>
        </tr>
      }

      def initialize(invitation)
        @invitation = invitation
        super
      end

      hidden
      def id
        @invitation.id.to_s
      end

      hidden
      def token
        @invitation.token
      end

      desc "Returns email address."
      def email
        @invitation.email.to_s
      end

      desc "Returns true if the invitation was accepted."
      def accepted?
        @invitation.accepted?
      end

      desc "Returns a date if the invitation was accepted."
      example %{
       {{ invitation.accepted_at | date: i18n.short_date }}
      }
      def accepted_at
        @invitation.accepted_at
      end

      desc "Returns the creation date."
      example %{
       {{ invitation.sent_at | date: i18n.short_date }}
      }
      def sent_at
        @invitation.sent_at.nil? ? @invitation.created_at : @invitation.sent_at
      end

      desc "Returns the URL to resend the invitation."
      example %{
        {{ "Resend" | update_button: invitation.resend_url}}
      }
      def resend_url
        resend_admin_account_invitation_path(@invitation)
      end

      desc "Returns the resource URL."
      example %{
        {{ "Delete" | delete_button: invitation.url }}
      }
      def url
        admin_account_invitation_path(@invitation)
      end
    end
  end
end
