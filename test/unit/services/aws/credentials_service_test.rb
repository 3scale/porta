# frozen_string_literal: true

require 'test_helper'

class Aws::CredentialsServiceTest < ActiveSupport::TestCase
  setup do
    File.stubs(:exist?).returns(true)
  end

  test '#call returns STS credentials when available' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(
      web_identity_token_file: params_for_sts_credentials[:web_identity_token_file],
      role_arn: params_for_sts_credentials[:role_name],
      role_session_name: params_for_sts_credentials[:role_session_name]
    ).returns(assume_role_response)

    assert Aws::CredentialsService.call(params_for_sts_credentials), { credentials: assume_role_response }
  end

  test '#call uses a default role session name for STS credentials if not provided' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(
      web_identity_token_file: params_for_sts_credentials[:web_identity_token_file],
      role_arn: params_for_sts_credentials[:role_name],
      role_session_name: '3scale-porta'
    ).returns(assume_role_response)

    assert Aws::CredentialsService.call(
      params_for_sts_credentials.except(:role_session_name)
    ), { credentials: assume_role_response }
  end

  test '#call returns AWS default credentials when STS ones are not available' do
    params_for_aws_credentials = full_params.slice(:access_key_id, :secret_access_key)

    Aws::AssumeRoleWebIdentityCredentials.expects(:new).never

    assert Aws::CredentialsService.call(params_for_aws_credentials), {
      access_key_id: params_for_aws_credentials[:access_key_id],
      secret_access_key: params_for_aws_credentials[:secret_access_key]
    }
  end

  test '#call does not try to assume role if the web_identity_token_file does not exist' do
    File.stubs(:exist?).with(params_for_sts_credentials[:web_identity_token_file]).returns(false)

    Aws::AssumeRoleWebIdentityCredentials.expects(:new).never

    assert Aws::CredentialsService.call(params_for_sts_credentials)
  end

  private

  def full_params
    {
      access_key_id: 'access_key_id',
      secret_access_key: 'secret_access_key',
      web_identity_token_file: '/path/to/token',
      role_name: 'ROLE_NAME',
      role_session_name: 'role_session_name'
    }
  end

  def params_for_sts_credentials
    full_params.slice(:web_identity_token_file, :role_name, :role_session_name)
  end

  def assume_role_response
    @assume_role_response ||= Aws::STS::Types::AssumeRoleWithWebIdentityResponse.new
  end
end
