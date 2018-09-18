# encoding: UTF-8

module Liquid
  module Drops
    class CurrentUser < Drops::User

      allowed_names :current_user

      desc "Exposes rights of current user which are dependent\n on your settings and user's role.
        \n You can call these methods on the returned object:\n\n - invite_user?\n - create_application?"

      example %{(
        {% if current_user.can.invite_users? %}
           {{ '<i class="fa fa-trash pull-right"></i>' | html_safe | link_to: invitation.url, class: 'pull-right btn btn-link', method: 'delete' }}
        {% endif %}
      )}
      def can
        ::Liquid::Drops::CurrentUser::Can.new(@user)
      end

      desc 'Returns SSO Authorizations collection.'
      def sso_authorizations
        Drops::Collection.for_drop(Drops::SSOAuthorization).new(@user.sso_authorizations)
      end

      class Can < Drops::Base

        def initialize(user)
          @user = user
          @provider = user.account.provider_account
        end

        desc "Returns true if can invite users."
        def invite_users?
          ability.can?(:create, ::Invitation)
        end

        desc """User can create application if he/she:

                 - has permission to do so
                 - there is a published (or default) application plan available for at least one service
             """
        def create_application?
          @provider.services.any? do |service|
            ability.can?(:create_application, service) and
              @user.account.can_create_application?(service)
          end
        end

        private

        def ability
          @ability ||= ::Ability.new(@user)
        end
      end
    end
  end
end
