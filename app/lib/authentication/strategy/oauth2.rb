# frozen_string_literal: true

require_dependency 'authentication/strategy'

module Authentication
  module Strategy
    class Oauth2 < Authentication::Strategy::Oauth2Base
      class FindOrCreateAccount < Procedure

        def call
          find_user || create_account(session)
        end

        private

        def find_user
          Users::FindOauth2UserService.run(user_data, authentication_provider, users).user.tap do |user|
            strategy.user_used_sso_authorization(user, user_data) if user
          end
        end

        def create_account(session)
          signup_result = new_user_created = nil

          Account.transaction do
            signup_result = SignupService.create(signup_service_params(session))
            if new_user_created = signup_result.persisted?
              if authentication_provider.automatically_approve_accounts? && !signup_result.account_approved?
                signup_result.account_approve!
              end
              if user_data.email_verified? && !signup_result.user_active?
                signup_result.user_activate!
              end
            end
            strategy.instance_variable_set(:@new_user_created, new_user_created)
          end

          signup_result.user if new_user_created
        end

        def signup_service_params(session)
          { provider: site_account, plans: [], session: session,
            account_params: { org_name: user_data.org_name }, user_params: user_data.to_hash }
        end

        def session
          @session ||= build_session
        end

        def build_session
          session = params.fetch(:request).session
          session[:id_token] ||= user_data.id_token
          session[:authentication_id] ||= (user_data.authentication_id || user_data.uid)
          session[:authentication_provider] ||= authentication_provider.system_name
          session
        end

        def site_account
          @site_account ||= users.proxy_association.owner
        end
      end

      class CreateInvitedUser < Procedure

        def call
          user = invitation.make_user(user_data.to_hash)
          strategy.user_used_sso_authorization(user, user_data)

          user.activate

          user
        end

        private

        def invitation
          params[:invitation]
        end
      end

      self.authenticate_procedure = FindOrCreateAccount

      protected

      def authentication_providers
        site_account.authentication_providers
      end
    end
  end
end
