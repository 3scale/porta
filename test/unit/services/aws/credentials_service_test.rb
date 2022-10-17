# frozen_string_literal: true

require 'test_helper'

class Aws::CredentialsServiceTest < ActiveSupport::TestCase
  test '#call returns IAM credentials when available' do
    CMS::STS::AssumeRoleWebIdentity.instance.expects(:identity_credentials).never

    assert Aws::CredentialsService.call(iam_auth_params), iam_auth_params
  end

  test '#call returns STS credentials when available' do
    Rails.application.config.stubs(:s3).returns(
      region: sts_auth_params[:region],
      role_arn: sts_auth_params[:role_arn],
      role_session_name: sts_auth_params[:role_session_name],
      web_identity_token_file: sts_auth_params[:web_identity_token_file]
    )

    CMS::STS::AssumeRoleWebIdentity.instance.expects(:identity_credentials).returns(sts_credentials)

    assert Aws::CredentialsService.call(sts_auth_params), { credentials: sts_credentials }
  end

  test '#call returns IAM credentials when both authentication types are available' do
    CMS::STS::AssumeRoleWebIdentity.instance.expects(:identity_credentials).never

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
end
