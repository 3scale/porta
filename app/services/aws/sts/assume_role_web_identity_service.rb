# frozen_string_literal: true

module Aws
  module Sts
    class AssumeRoleWebIdentityService
      include Singleton

      class TokenNotFoundError < StandardError
      end

      def identity_credentials
        @identity_credentials ||= Aws::AssumeRoleWebIdentityCredentials.new(params)
      end

      def config(params)
        @params = params
        raise TokenNotFoundError, "web_identity_token_file was not found" unless web_identity_token_file_exists?

        self
      end

      private

      attr_reader :params

      def web_identity_token_file_exists?
        File.exist?(params[:web_identity_token_file])
      end
    end
  end
end
