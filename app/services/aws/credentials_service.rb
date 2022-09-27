# frozen_string_literal: true

module Aws
  class CredentialsService
    class << self
      def call(params = {})
        new(params).call
      end
    end

    attr_reader :params

    ROLE_SESSION_NAME = '3scale-porta'

    def initialize(params)
      @params = params
    end

    # @return [Hash] Depending on the available connections, this method may return:
    # When STS credentials are available: { credentials: Aws::STS::Types::AssumeRoleWithWebIdentityResponse };
    # When STS credentials are not available: { web_identity_token_file: 'foo', role_name: 'bar' };
    # When no configurations are available: An empy Hash{};
    def call
      if sts_params.any? && sts_params.all? { |_key, value| value.present? } && web_identity_token_file_exists?
        { credentials: sts_credentials }
      else
        iam_credentials
      end
    end

    private

    def iam_credentials
      params.slice(:access_key_id, :secret_access_key)
    end

    def sts_credentials
      Aws::AssumeRoleWebIdentityCredentials.new(
        web_identity_token_file: sts_params[:web_identity_token_file],
        role_arn: sts_params[:role_name],
        role_session_name: params[:role_session_name].presence || ROLE_SESSION_NAME
      )
    end

    def sts_params
      params.slice(:web_identity_token_file, :role_name)
    end

    def web_identity_token_file_exists?
      File.exist?(sts_params[:web_identity_token_file])
    end
  end
end
