# frozen_string_literal: true

require 'test_helper'

class Aws::CredentialsServiceTest < ActiveSupport::TestCase
  test '#call returns IAM credentials when available' do
    assume_role_web_identity_service_instance.expects(:identity_credentials).never

    assert Aws::CredentialsService.call(iam_auth_params), iam_auth_params
  end

  test '#call returns STS credentials when available' do
    assume_role_web_identity_service_instance
      .expects(:config)
      .with(sts_auth_params)
      .returns(assume_role_web_identity_service_instance)

    assume_role_web_identity_service_instance
      .expects(:identity_credentials)
      .returns(sts_credentials)

    assert Aws::CredentialsService.call(sts_auth_params), { credentials: sts_credentials }
  end

  test '#call returns IAM credentials when both authentication types are available' do
    assume_role_web_identity_service_instance.expects(:identity_credentials).never

    assert Aws::CredentialsService.call(full_params), iam_auth_params
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

  def sts_credentials
    @sts_credentials ||= Aws::Credentials.new(nil, nil)
  end

  def assume_role_web_identity_service_instance
    Aws::Sts::AssumeRoleWebIdentityService.instance
  end
end
