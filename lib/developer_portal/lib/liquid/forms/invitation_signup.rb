module Liquid
  module Forms
    class InvitationSignup < Forms::Create

      def form_options
        super.merge(id: 'signup_form'.freeze)
      end

      def path
        invitee_signup_path(invitation.token)
      end

      def invitation
        object.invitation
      end
    end
  end
end
