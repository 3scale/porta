# frozen_string_literal: true

require 'test_helper'

class CMS::STS::AssumeRoleWebIdentityTest < ActiveSupport::TestCase
  setup do
    File.stubs(:exist?).returns(true)
    assume_role_response.class.any_instance.stubs(:expiration).returns(1.minute.from_now)
    assume_role_response.stubs(:credentials).returns(sts_credentials)
    assume_role_web_identity_instance.instance_variable_set('@identity_credentials', nil)
  end

  test 'CMS::STS::AssumeRoleWebIdentity is a singleton' do
    assert CMS::STS::AssumeRoleWebIdentity.ancestors.include?(Singleton), true
  end

  test '#identity_credentials raises an error if the web_identity_token_file does not exist' do
    File.stubs(:exist?).with(sts_auth_params[:web_identity_token_file]).returns(false)
    assume_role_web_identity_instance.web_identity_token_file = sts_auth_params[:web_identity_token_file]

    assert_raises(CMS::STS::AssumeRoleWebIdentity::TokenNotFoundError) do
      assume_role_web_identity_instance.identity_credentials
    end
  end

  test '#identity_credentials calls AWS to get an instance of STS credentials' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).returns(assume_role_response)

    assume_role_web_identity_instance.web_identity_token_file = sts_auth_params[:web_identity_token_file]
    assume_role_web_identity_instance.role_arn = sts_auth_params[:role_arn]
    assume_role_web_identity_instance.role_session_name = sts_auth_params[:role_session_name]
    assume_role_web_identity_instance.region = sts_auth_params[:region]

    assert assume_role_web_identity_instance.identity_credentials, sts_credentials
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

  def assume_role_web_identity_instance
    CMS::STS::AssumeRoleWebIdentity.instance
  end
end
