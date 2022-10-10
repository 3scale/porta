# frozen_string_literal: true

module Aws
  module Sts
    class AssumeRoleWebIdentityService
      class << self
        def call(params = {})
          new(params).call
        end
      end

      class TokenNotFoundError < StandardError
      end

      def initialize(params)
        @params = params
      end

      def call
        raise TokenNotFoundError, "web_identity_token_file was not found" unless web_identity_token_file_exists?

        cached_call { Aws::AssumeRoleWebIdentityCredentials.new(params) }
      end

      private

      attr_reader :params

      def cached_call
        cached_value = ::Rails.cache.read(cache_key)
        return cached_value if cached_value.present?

        sts_response = yield

        ::Rails.cache.write(cache_key, sts_response, expires_in: cache_expires_in(sts_response.expiration))
      end

      def cache_expires_in(expiration_datetime)
        (expiration_datetime - Time.current).round.seconds
      end

      def cache_key
        "sts/#{params[:role_session_name]}/#{params[:web_identity_token_file]}/#{params[:role_arn]}/#{params[:region]}"
      end

      def web_identity_token_file_exists?
        File.exist?(params[:web_identity_token_file])
      end
    end
  end
end
