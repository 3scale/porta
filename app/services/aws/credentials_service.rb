# frozen_string_literal: true

module Aws
  class CredentialsService
    class << self
      def call(params = {})
        new(params).call
      end
    end

    class AuthenticationTypeError < StandardError
    end

    DEFAULT_ROLE_SESSION_NAME = '3scale-porta'
    IAM_KEYS = %i[access_key_id secret_access_key].freeze
    STS_KEYS = %i[region role_arn role_session_name web_identity_token_file].freeze

    def initialize(params)
      @params = params
    end

    # Returns either IAM or STS credentials to be used on calls to S3
    #
    # @param [Hash] Hash containing AWS credentials related keys
    # @return [Hash<Symbol, String>] with access_key_id and secret_access_key when IAM credentials are provided
    # @return [Hash<Symbol, Aws::AssumeRoleWebIdentityCredentials>] when STS credentials are provided
    # @raise [AuthenticationTypeError] if not enough params are provided
    def call
      if valid_params_with(iam_params, IAM_KEYS)
        iam_params
      elsif valid_params_with(sts_params, STS_KEYS)
        sts_temporary_security_credentials
      else
        raise AuthenticationTypeError, "Either #{IAM_KEYS} or #{STS_KEYS} must be provided."
      end
    end

    private

    attr_reader :params

    def valid_params_with(credentials, keys)
      return false if credentials.empty?
      return false if keys.difference(credentials.keys).any?

      credentials.all? { |_key, value| value.present? }
    end

    def sts_temporary_security_credentials
      { credentials: Sts::AssumeRoleWebIdentityService.call(sts_params) }
    end

    def iam_params
      @iam_params ||= params.slice(*IAM_KEYS)
    end

    def sts_params
      @sts_params ||= params.slice(*STS_KEYS).tap do |credentials|
        credentials[:role_session_name] ||= DEFAULT_ROLE_SESSION_NAME
      end
    end
  end
end
