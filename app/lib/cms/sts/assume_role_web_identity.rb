# frozen_string_literal: true

module CMS
  module STS
    class AssumeRoleWebIdentity
      include Singleton
      # :reek:Attribute
      attr_accessor :region, :role_arn, :role_session_name, :web_identity_token_file

      class TokenNotFoundError < StandardError
      end

      def identity_credentials
        @identity_credentials ||= begin
          validate_configuration

          Aws::AssumeRoleWebIdentityCredentials.new(
            region: region,
            role_arn: role_arn,
            role_session_name: role_session_name,
            web_identity_token_file: web_identity_token_file
          )
        end
      end

      private

      attr_reader :params

      def validate_configuration
        raise TokenNotFoundError, "web_identity_token_file was not found" unless web_identity_token_file_exists?
      end

      def web_identity_token_file_exists?
        ::File.exist?(web_identity_token_file)
      end
    end
  end
end
