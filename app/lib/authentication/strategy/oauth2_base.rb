# frozen_string_literal: true

require_dependency 'authentication/strategy'

module Authentication
  module Strategy
    class Oauth2Base < Authentication::Strategy::Internal

      def initialize(*)
        super
        @authentication_provider = nil
        @user_data = nil
        @user = nil
        @error_message = nil
        @user_for_signup = nil
      end

      class MissingAuthenticationProvider < StandardError; end

      attr_reader :user, :user_data
      class_attribute :authenticate_procedure

      class MissingProcedure < Procedure
        def call
          raise 'strategy is missing signup procedure'
        end
      end

      self.authenticate_procedure = MissingProcedure

      def authenticate(params, procedure: authenticate_procedure)
        return super(params) unless find_authentication_provider(params[:system_name])
        authenticate_client(params, procedure)
        active_user(@user)
      end

      def active_user(user)
        return false unless user

        if user.can_login?
          user
        else
          self.error_message = inactive_user_message
          false
        end
      end

      def signup_path(params)
        super(params.except(:code, :system_name))
      end

      def redirects_to_signup?
        if authentication_provider_exists?
          @error_message.blank? && !@user
        else
          super
        end
      end

      def on_signup(session)
        return unless @user_data

        session[:authentication_kind]     = user_data.kind
        session[:authentication_id]       = user_data.uid
        session[:authentication_username] = user_data.username
        session[:authentication_provider] = authentication_provider.system_name
        session[:authentication_email]    = user_data.verified_email
        session[:id_token]                = user_data.id_token
      end

      def on_signup_complete(session)
        if @user_for_signup && !@user_for_signup.active? && authentication_email_match?(session)
          @user_for_signup.activate!
        end

        session[:authentication_id] = nil
        session[:authentication_email] = nil
        session[:authentication_username] = nil
        session[:authentication_kind] = nil
        session[:authentication_provider] = nil
        session[:id_token] = nil
      end

      def on_new_user(user, session)
        uid = session[:authentication_id]
        system_name = session[:authentication_provider]
        return if uid.blank? || system_name.blank?
        find_authentication_provider(system_name)
        user_used_sso_authorization(user, ThreeScale::OAuth2::UserData.new(uid: uid, id_token: session[:id_token]))
        assign_sso_attributes(user, session)
        @user_for_signup = user
      end

      def track_signup_options(options = {})
        if @user_for_signup && @user_for_signup.signup.oauth2?
          { kind: options[:session][:authentication_kind], strategy: 'oauth2' }
        else
          super(options)
        end
      end

      def user_used_sso_authorization(user, user_data)
        authorization = SSOAuthorization.find_or_build_as_used(user: user, uid: user_data.uid, authentication_provider: authentication_provider, id_token: user_data.id_token)
        authorization.save && user.save if user.persisted?
      end

      def authentication_provider
        @authentication_provider or raise MissingAuthenticationProvider
      end

      private

      def authentication_email_match?(session)
        @user_for_signup.email == session[:authentication_email]
      end

      def authenticate_client(params, procedure)
        client = ThreeScale::OAuth2::Client.build(authentication_provider)
        case (@user_data = client.authenticate!(params[:code], params[:request]))
        when ThreeScale::OAuth2::UserData
          @user ||= procedure.new(self, users, params, user_data).call or return false
        when ThreeScale::OAuth2::ErrorData
          @error_message = user_data.error.presence
        end
      end

      def authentication_provider_exists?
        @authentication_provider.present?
      end

      def assign_sso_attributes(user, session)
        user.username ||= session[:authentication_username].presence
        user.email ||= session[:authentication_email].presence
      end

      def authentication_providers
        raise NotImplementedError, "#{__method__} not implemented in #{self.class}"
      end

      def find_authentication_provider(system_name)
        @authentication_provider ||= authentication_providers.find_by(system_name: system_name)
      end
    end
  end
end
