# frozen_string_literal: true

require 'test_helper'

class Aws::Sts::AssumeRoleWebIdentityServiceTest < ActiveSupport::TestCase
  setup do
    File.stubs(:exist?).returns(true)
    assume_role_response.class.any_instance.stubs(:expiration).returns(1.minute.from_now)
  end

  test '#call calls AWS to get an instance of STS credentials' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).returns(assume_role_response)

    assert Aws::Sts::AssumeRoleWebIdentityService.call(sts_auth_params), assume_role_response
  end

  test '#call caches the AWS response when it is successful' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).returns(assume_role_response)

    Rails.cache.expects(:write)
      .with(sts_cache_key, assume_role_response, expires_in: 1.minute.seconds)
      .returns(assume_role_response)

    assert Aws::Sts::AssumeRoleWebIdentityService.call(sts_auth_params), assume_role_response
  end

  test '#call does not cache the AWS response when it fails' do
    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).raises(invalid_token_error)

    Rails.cache.expects(:write).never

    assert_raises(invalid_token_error.class) do
      Aws::Sts::AssumeRoleWebIdentityService.call(sts_auth_params)
    end

    assert_nil Rails.cache.read(sts_cache_key)
  end

  test '#call raises an error if the web_identity_token_file does not exist' do
    File.stubs(:exist?).with(sts_auth_params[:web_identity_token_file]).returns(false)

    assert_raises(Aws::Sts::AssumeRoleWebIdentityService::TokenNotFoundError) do
      Aws::Sts::AssumeRoleWebIdentityService.call(sts_auth_params)
    end
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

  def sts_cache_key
    "sts/#{sts_auth_params[:role_session_name]}/#{sts_auth_params[:web_identity_token_file]}/"\
    "#{sts_auth_params[:role_arn]}/#{sts_auth_params[:region]}"
  end

  def invalid_token_error
    Aws::STS::Errors::InvalidIdentityToken.new(nil, 'error')
  end
end
