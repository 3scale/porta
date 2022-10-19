require 'test_helper'

class CMS::S3Test < ActiveSupport::TestCase
  test "S3 detection of fips environment" do
    FakeFS.with_fresh do
      FileUtils.mkdir_p(File.dirname(CMS::S3::FIPS_FILE_PATH))
      File.write(CMS::S3::FIPS_FILE_PATH, "1\n")
      assert CMS::S3.fips_environment?
      assert CMS::S3.options[:use_fips_endpoint]
      assert CMS::S3.options[:s3_us_east_1_regional_endpoint]
    end
  end

  test "S3 detection when non-fips" do
    FakeFS.with_fresh do
      FileUtils.mkdir_p(File.dirname(CMS::S3::FIPS_FILE_PATH))
      File.write(CMS::S3::FIPS_FILE_PATH, "0\n")
      assert_not CMS::S3.fips_environment?
      assert_not CMS::S3.options[:use_fips_endpoint]
      assert_not CMS::S3.options[:s3_us_east_1_regional_endpoint]
    end
  end

  test "S3 detection without fips file" do
    FakeFS.with_fresh do
      assert_not CMS::S3.fips_environment?
      assert_not CMS::S3.options[:use_fips_endpoint]
      assert_not CMS::S3.options[:s3_us_east_1_regional_endpoint]
    end
  end

  test "S3 detection with failing file read" do
    File.expects(:file?).with(CMS::S3::FIPS_FILE_PATH).returns(true).at_least_once
    File.expects(:read).with(CMS::S3::FIPS_FILE_PATH).raises.at_least_once
    assert_not CMS::S3.fips_environment?
    assert_not CMS::S3.options[:use_fips_endpoint]
    assert_not CMS::S3.options[:s3_us_east_1_regional_endpoint]
  end

  test ":use_fips_endpoint S3 option overrides auto-detection" do
    CMS::S3.stubs(:fips_environment?).returns(true)
    assert CMS::S3.options[:use_fips_endpoint]
    assert CMS::S3.options[:s3_us_east_1_regional_endpoint]

    config = CMS::S3.send(:config).merge(use_fips_endpoint: false)
    CMS::S3.stubs(:config).returns(config)
    assert_not CMS::S3.options[:use_fips_endpoint]
    assert_not CMS::S3.options[:s3_us_east_1_regional_endpoint]
  end

  test ":force_path_style and :use_fips_endpoint options incompatible" do
    CMS::S3.stubs(:config).returns(use_fips_endpoint: true, force_path_style: true)
    assert_raises(ArgumentError) { CMS::S3.options }
  end

  test ":use_fips_endpoint and dots in bucket name are incompatible" do
    CMS::S3.stubs(:config).returns(bucket: "name.with.dots", use_fips_endpoint: true)
    assert_raises(ArgumentError) { CMS::S3.options }
  end

  test ":use_fips_endpoint is not set when custom endpoint is" do
    CMS::S3.expects(:fips_environment?).returns(true).never
    CMS::S3.stubs(:config).returns(protocol: "https", hostname: "test.example.com")
    assert CMS::S3.options[:endpoint]
    assert_not CMS::S3.options[:use_fips_endpoint]
  end

  test "#credentials returns nil when CMS::S3 is not enabled" do
    CMS::S3.stubs(:enabled?).returns(false)

    assert_equal CMS::S3.credentials, nil
  end

  test "#credentials calls Aws::CredentialsService with the correct arguments" do
    Aws::CredentialsService.expects(:call).with(CMS::S3.send(:config))

    CMS::S3.credentials
  end

  test "#role_arn returns nil when CMS::S3 is not enabled" do
    CMS::S3.stubs(:enabled?).returns(false)

    assert_equal CMS::S3.role_arn, nil
  end

  test "#role_arn returns the correct config data" do
    role_arn = 'some:arn'
    CMS::S3.stubs(:config).returns(role_arn: role_arn)

    assert_equal CMS::S3.role_arn, role_arn
  end

  test "#role_session_name returns nil when CMS::S3 is not enabled" do
    CMS::S3.stubs(:enabled?).returns(false)

    assert_equal CMS::S3.role_session_name, nil
  end

  test "#role_session_name returns the correct config data" do
    role_session_name = 'some-session-name'
    CMS::S3.stubs(:config).returns(role_session_name: role_session_name)

    assert_equal CMS::S3.role_session_name, role_session_name
  end

  test "#web_identity_token_file returns nil when CMS::S3 is not enabled" do
    CMS::S3.stubs(:enabled?).returns(false)

    assert_equal CMS::S3.web_identity_token_file, nil
  end

  test "#web_identity_token_file returns the correct config data" do
    web_identity_token_file = 'path/to/token'
    CMS::S3.stubs(:config).returns(web_identity_token_file: web_identity_token_file)

    assert_equal CMS::S3.web_identity_token_file, web_identity_token_file
  end
end
