# frozen_string_literal: true

require 'test_helper'

class Aws::AwsCredentialsTest < ActiveSupport::TestCase
  setup do
    CMS::AwsCredentials.instance.instance_variable_set('@credentials', nil)
  end

  teardown do
    CMS::AwsCredentials.instance.instance_variable_set('@credentials', nil)
  end

  test 'returns IAM credentials when available' do
    iam_params!
    CMS::AwsCredentials.instance.expects(:sts_credentials).never

    assert_equal iam_auth_params, CMS::AwsCredentials.instance.credentials
  end

  test 'returns STS credentials when available' do
    sts_params!
    CMS::AwsCredentials.instance.expects(:sts_credentials).returns(sts_credentials)

    assert_equal({ credentials: sts_credentials }, CMS::AwsCredentials.instance.credentials)
  end

  test 'returns IAM credentials when both authentication types are available' do
    full_params!
    CMS::AwsCredentials.instance.expects(:sts_credentials).never

    assert_equal iam_auth_params, CMS::AwsCredentials.instance.credentials
  end

  test 'raises an error if not enough credential params are present' do
    CMS::S3.stubs(:config).returns(full_params.except(:role_arn, :access_key_id))

    assert_raises(CMS::AwsCredentials::AuthenticationTypeError) do
      CMS::AwsCredentials.instance.credentials
    end
  end

  test 'is a singleton' do
    assert CMS::AwsCredentials.ancestors.include?(Singleton), true
  end

  test 'raises an error if the web_identity_token_file does not exist' do
    sts_params!

    assert_raises(CMS::AwsCredentials::TokenNotFoundError) do
      CMS::AwsCredentials.instance.credentials
    end
  end

  test 'calls AWS to get an instance of STS credentials' do
    sts_params!

    CMS::S3.stub!

    with_fake_token do
      assert_instance_of Aws::AssumeRoleWebIdentityCredentials, CMS::AwsCredentials.instance.send(:sts_credentials)
      assert_operator CMS::AwsCredentials.instance.send(:sts_credentials).client.api_requests.size, :>, 0
    end
  end

  test 'STS credentials are created with correct parameters' do
    sts_params!
    File.stubs(:exist?).with(full_params[:web_identity_token_file]).returns(true)

    Aws::AssumeRoleWebIdentityCredentials.expects(:new).with(sts_auth_params).returns(sts_credentials)
    assert_equal sts_credentials, CMS::AwsCredentials.instance.send(:sts_credentials)
  end

  private

  def full_params
    {
      access_key_id: 'my_access_key_id',
      secret_access_key: 'my_secret_access_key',
      web_identity_token_file: '/path/to/token',
      role_arn: 'my_role_arn',
      role_session_name: 'my_role_session_name',
      region: 'my-region'
    }
  end

  def iam_auth_params
    full_params.slice(*CMS::AwsCredentials::IAM_KEYS)
  end

  def sts_auth_params
    full_params.slice(:region, *CMS::AwsCredentials::STS_KEYS)
  end

  def iam_params!
    CMS::S3.stubs(:config).returns(full_params.except(*CMS::AwsCredentials::STS_KEYS))
  end

  def sts_params!
    CMS::S3.stubs(:config).returns(full_params.except(*CMS::AwsCredentials::IAM_KEYS))
  end

  def full_params!
    CMS::S3.stubs(:config).returns(full_params)
  end

  def sts_credentials
    @sts_credentials ||= Aws::Credentials.new(nil, nil)
  end

  def with_fake_token
    FakeFS do
      FakeFS::FileSystem.clone(Gem.loaded_specs['aws-partitions'].full_gem_path)
      FileUtils.mkdir_p(File.dirname(full_params[:web_identity_token_file]))
      File.write(full_params[:web_identity_token_file], "akhsdkjfskdfjkdshfkjd")
      yield
    end
  end
end
