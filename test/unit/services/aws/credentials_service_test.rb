# frozen_string_literal: true

require 'test_helper'

class Aws::CredentialsServiceTest < ActiveSupport::TestCase
  setup do
    File.stubs(:exist?).returns(true)
  end

  test '#call returns IAM credentials when available' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).never

    assert Aws::CredentialsService.call(iam_auth_params), {
      access_key_id: iam_auth_params[:access_key_id],
      secret_access_key: iam_auth_params[:secret_access_key]
    }
  end

  test '#call returns STS credentials when available' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).returns(assume_role_response)

    assert Aws::CredentialsService.call(sts_auth_params), { credentials: assume_role_response }
  end

  test '#call uses a default role session name for STS credentials if not provided' do
    Aws::AssumeRoleWebIdentityCredentials
      .expects(:new)
      .with(sts_auth_params.merge(role_session_name: '3scale-porta'))
      .returns(assume_role_response)

    assert Aws::CredentialsService.call(
      sts_auth_params.except(:role_session_name)
    ), { credentials: assume_role_response }
  end

  test '#call raises an error if the web_identity_token_file does not exist' do
    File.stubs(:exist?).with(sts_auth_params[:web_identity_token_file]).returns(false)

    Aws::AssumeRoleWebIdentityCredentials.expects(:new).never

    assert_raises(Aws::CredentialsService::TokenNotFoundError) do
      Aws::CredentialsService.call(sts_auth_params)
    end
  end

  test '#call raises an error if not enough credential params are present' do
    assert_raises(Aws::CredentialsService::AuthenticationTypeError) do
      Aws::CredentialsService.call(full_params.except(:access_key_id, :role_arn))
    end
  end

  private

  def full_params
    {
      access_key_id: 'access_key_id',
      secret_access_key: 'secret_access_key',
      web_identity_token_file: '/path/to/token',
      role_arn: 'role_arn',
      role_session_name: 'role_session_name',
      region: 'region'
    }
  end

  def iam_auth_params
    full_params.slice(:access_key_id, :secret_access_key)
  end

  def sts_auth_params
    full_params.slice(:region, :role_arn, :role_session_name, :web_identity_token_file)
  end

  def assume_role_response
    @assume_role_response ||= Aws::STS::Types::AssumeRoleWithWebIdentityResponse.new
  end
end
