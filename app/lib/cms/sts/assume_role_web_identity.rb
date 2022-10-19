# frozen_string_literal: true

module CMS
  module STS
    class AssumeRoleWebIdentity
      include Singleton

      class TokenNotFoundError < StandardError
      end

      def identity_credentials
        @identity_credentials ||= begin
          check_token_presence

          Aws::AssumeRoleWebIdentityCredentials.new(
            region: S3.region,
            role_arn: S3.role_arn,
            role_session_name: S3.role_session_name,
            web_identity_token_file: S3.web_identity_token_file
          )
        end
      end

      private

      def check_token_presence
        raise TokenNotFoundError, "web_identity_token_file was not found" unless web_identity_token_file_exists?
      end

      def web_identity_token_file_exists?
        ::File.exist?(S3.web_identity_token_file)
      end
    end
  end
end
