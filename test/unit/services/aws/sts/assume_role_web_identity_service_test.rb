# frozen_string_literal: true

require 'test_helper'

class Aws::Sts::AssumeRoleWebIdentityServiceTest < ActiveSupport::TestCase
  setup do
    File.stubs(:exist?).returns(true)
    assume_role_response.class.any_instance.stubs(:expiration).returns(1.minute.from_now)
    assume_role_response.stubs(:credentials).returns(sts_credentials)
  end

  test '#config sets params' do
    assert(
      assume_role_web_identity_service_instance.config(sts_auth_params).as_json['params'].keys.sort,
      ['region', 'role_arn', 'role_session_name', 'web_identity_token_file']
    )
  end

  test '#config returns self' do
    assert assume_role_web_identity_service_instance.config(sts_auth_params), assume_role_web_identity_service_instance
  end

  test '#config raises an error if the web_identity_token_file does not exist' do
    File.stubs(:exist?).with(sts_auth_params[:web_identity_token_file]).returns(false)

    assert_raises(Aws::Sts::AssumeRoleWebIdentityService::TokenNotFoundError) do
      assume_role_web_identity_service_instance.config(sts_auth_params)
    end
  end

  test '#identity_credentials calls AWS to get an instance of STS credentials' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).returns(assume_role_response)
    assume_role_web_identity_service_instance.config(sts_auth_params)

    assert assume_role_web_identity_service_instance.identity_credentials, sts_credentials
  end

  private

  def sts_auth_params
    {
      web_identity_token_file: '/path/to/token',
      role_arn: 'role_arn',
      role_session_name: 'role_session_name',
      region: 'region'
    }
  end

  def assume_role_response
    @assume_role_response ||= Aws::STS::Types::AssumeRoleWithWebIdentityResponse.new
  end

  def sts_credentials
    @sts_credentials ||= Aws::Credentials.new(nil, nil)
  end

  def invalid_token_error
    @invalid_token_error ||= Aws::STS::Errors::InvalidIdentityToken.new(nil, 'error')
  end

  def assume_role_web_identity_service_instance
    Aws::Sts::AssumeRoleWebIdentityService.instance
  end
end
