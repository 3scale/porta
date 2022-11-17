# frozen_string_literal: true

module CMS
  class AwsCredentials
    include Singleton

    class AuthenticationTypeError < StandardError
    end

    IAM_KEYS = %i[access_key_id secret_access_key].freeze
    STS_KEYS = %i[role_arn role_session_name web_identity_token_file].freeze

    # Returns either IAM or STS credentials to be used on calls to S3
    #
    # @return [Hash<Symbol, String>] with access_key_id and secret_access_key when IAM credentials are provided
    # @return [Hash<Symbol, Aws::AssumeRoleWebIdentityCredentials>] when STS credentials are provided
    # @raise [AuthenticationTypeError] if not enough params are provided
    def credentials
      @credentials ||=
        if params?(IAM_KEYS)
          iam_params
        elsif params?(STS_KEYS)
          { credentials: sts_credentials }
        else
          raise AuthenticationTypeError, "Either #{IAM_KEYS} or #{STS_KEYS} must be provided."
        end
    end

    private

    def params?(keys)
      keys.all? { |key| S3.public_send(key).present? }
    end

    def sts_credentials
      Aws::AssumeRoleWebIdentityCredentials.new(
        region: S3.region,
        role_arn: S3.role_arn,
        role_session_name: S3.role_session_name,
        web_identity_token_file: S3.web_identity_token_file
      )
    end

    def iam_params
      IAM_KEYS.map { |key| [key, S3.public_send(key)] }.to_h
    end
  end
end
