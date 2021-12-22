# frozen_string_literal: true

require 'test_helper'

class EmailConfigurationTest < ActiveSupport::TestCase
  setup do
    @email_configuration = FactoryBot.create(:email_configuration)
  end

  test "should not merge global SMTP settings for non-auth changes" do
    set_global_config

    local_settings = {
      user_name: "local_username",
      password: "local_password",
      tls: "starttls",
      address: "another.smtp.example.com",
    }

    config = FactoryBot.create(:email_configuration, **local_settings)

    %i[user_name password address].each do |attr|
      assert_equal local_settings[attr], config.smtp_settings[attr]
    end

    assert config.smtp_settings[:enable_starttls]

    %i[enable_starttls_auto tls port openssl_verify_mode domain].each do |attr|
      assert_not config.smtp_settings[attr]
    end
  end

  test "should merge global SMTP settings when only auth is set" do
    set_global_config

    local_settings = {
      user_name: "local_username",
      password: "local_password",
      domain: "custom.example.com",
    }

    config = FactoryBot.create(:email_configuration, **local_settings)

    %i[user_name password domain].each do |attr|
      assert_equal local_settings[attr], config.smtp_settings[attr]
    end

    %i[enable_starttls_auto enable_starttls tls port address openssl_verify_mode].each do |attr|
      assert_equal global_settings[attr], config.smtp_settings[attr]
    end
  end

  test "account should be provider" do
    account = FactoryBot.create(:buyer_account)
    config = FactoryBot.build(:email_configuration, account: account)
    assert config.invalid?
  end

  test "email address should be unique case insensitive" do
    config = FactoryBot.build(:email_configuration, email: @email_configuration.email.upcase)
    assert config.invalid?
    assert_not_equal @email_configuration.email, config.email
  end

  test 'search by email should be case insensitive' do
    email = @email_configuration.email.upcase
    configs = EmailConfiguration.for(email)
    assert_equal 1, configs.size

    config = configs.first
    assert_equal @email_configuration, config
    assert_not_equal @email_configuration.email, email
  end

  test 'special characters should be escaped in search' do
    samples = %w[a@example.com a_a@example.com %a@example.com]
    confusables = %w[aaa@example.com a@example.comx]
    records = confusables + samples

    records.each do |record|
      FactoryBot.create(:email_configuration, email: record, account: @email_configuration.account)
    end
    FactoryBot.create(:email_configuration, account: @email_configuration.account).update_column(:email, "A\\a@example.com") # rubocop:disable Rails/SkipsModelValidations

    samples.concat ["a\\a@example.com"]

    samples.each do |sample|
      assert_equal 1, EmailConfiguration.for(sample).size
    end
  end

  test 'port number can be set to the maximum 16 bit integer' do
    @email_configuration.port = 65535
    @email_configuration.address = "override.example.com"
    @email_configuration.save!
    @email_configuration.reload
    assert_equal 65535, @email_configuration.port
  end

  private

  def global_settings
    {
      address: "smtp.global.example.com",
      port: 465,
      user_name: "global-username",
      password: "global-password",
      enable_starttls_auto: true,
      enable_starttls: false,
      tls: true,
    }.freeze
  end

  def set_global_config
    ActionMailer::Base.stubs(:smtp_settings).returns(global_settings)
  end
end
