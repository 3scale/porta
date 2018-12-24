# encoding: utf-8
require 'test_helper'

class SSOTokenTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create :provider_account
  end

  test "creating a valid sso token using user_id" do
    buyer     = FactoryBot.create(:buyer_account, :provider_account => @provider)

    sso_token = SSOToken.new :user_id => buyer.users.first.id, :account => @provider, :expires_in => 6000

    # mass-assignment should take care of this.
    assert_nil sso_token.account
    sso_token.account= @provider

    assert sso_token.save

    assert_not_nil sso_token.encrypted_token
    assert_not_nil sso_token.expires_at
  end

  test "creating a valid sso token using username" do
    buyer     = FactoryBot.create(:buyer_account, :provider_account => @provider)

    sso_token = SSOToken.new :username => buyer.users.first.username
    sso_token.account= @provider

    assert sso_token.save

    assert_not_nil sso_token.encrypted_token
    assert_equal 10.minutes, sso_token.expires_in
  end

  test "user_id or username validations" do
    sso_token = SSOToken.new
    sso_token.account = @provider

    refute sso_token.valid?
    assert_equal I18n.t('activemodel.errors.models.sso_token.one_of_user_id_or_username_is_required'),
      sso_token.errors[:base].first

    sso_token.username= @provider.managed_users.sample.username
    assert sso_token.valid?
    sso_token.username= nil

    refute sso_token.valid?

    sso_token.user_id= @provider.managed_users.sample.id
    assert sso_token.valid?
  end

  test "user and account validations" do
    sso_token = SSOToken.new :username => FactoryBot.create(:user).username

    assert_equal 600, sso_token.expires_in

    sso_token.account = Hash.new
    refute sso_token.valid?
    refute sso_token.errors[:account].empty?

    buyer = FactoryBot.create(:buyer_account)

    sso_token.account = buyer
    refute sso_token.valid?
    refute sso_token.errors[:account].empty?

    sso_token.account = buyer.provider_account

    refute sso_token.valid?
    refute sso_token.errors[:username].empty?
  end

  test "validating and passing redirect_url" do
    sso_token = SSOToken.new(username: @provider.managed_users.sample.username)
    sso_token.account = @provider

    assert sso_token.valid?

    refute_match /redirect_url/, sso_token.sso_url!

    sso_token.redirect_url = 'http://example.net'
    assert sso_token.valid?

    assert sso_token.sso_url! =~ /^https/

    sso_token.redirect_url = CGI.escape('http://example.net/index.php?photo_id=5&next=100')
    assert sso_token.valid?

    sso_token.redirect_url = "http:"
    refute sso_token.valid?

    refute sso_token.errors[:redirect_url].empty?
  end

  test "invalid protocol" do
    sso_token = SSOToken.new(username: @provider.managed_users.sample.username, protocol: 'ftp')
    sso_token.account = @provider

    refute sso_token.valid?
    refute sso_token.errors[:protocol].empty?

    sso_token.protocol = 'http'
    assert sso_token.sso_url! =~ /^http/
  end

  test "passing protocol" do
    sso_token = SSOToken.new(username: @provider.managed_users.sample.username, protocol: 'http')
    sso_token.account = @provider

    assert sso_token.valid?
    assert sso_token.sso_url! =~ /^http/
  end

  test "invalid sso-key" do
    @provider.settings.update_attribute :sso_key, "ABC"

    sso_token = SSOToken.new(user_id: @provider.managed_users.sample.id)
    sso_token.account = @provider

    refute sso_token.save

    assert_match /cannot be generated/, sso_token.errors[:base].first
  end
end
