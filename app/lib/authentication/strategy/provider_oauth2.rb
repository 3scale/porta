require_dependency 'authentication/strategy'

module Authentication
  module Strategy
    class ProviderOauth2 < Authentication::Strategy::Oauth2Base

      class FindOrCreateUser < Procedure

        def call
          (active_user(find_user) || create_user(session)).tap do |user|
            strategy.user_used_sso_authorization(user, ThreeScale::OAuth2::UserData.new(uid: uid)) if user
          end
        end

        private

        def find_user
          result = Users::FindOauth2UserService.run(user_data, authentication_provider, users)
          strategy.error_message = result.error_message
          result.user
        end

        def active_user(user)
          return unless user
          return user if user.active?

          user if user.activate_email(user_data.verified_email)
        end

        def create_user(session)
          user = users.build(user_data.to_hash)
          user.signup_type = :created_by_provider

          strategy.on_new_user(user, session)

          if strategy.instance_variable_set(:@new_user_created, user.save)
            # FIXME: this should be handled by some of the on_* callbacks
            unless user.activate_email(user_data.verified_email)
              ProviderUserMailer.activation(user).deliver_now
              ActivationReminderWorker.enqueue(user)
            end
          end

          user
        end

        def session
          @session ||= params.fetch(:request).session
        end

        def site_account
          @site_account ||= users.proxy_association.owner
        end
      end

      self.authenticate_procedure = FindOrCreateUser


      protected

      def authentication_providers
        site_account.self_authentication_providers
      end
    end
  end
end
