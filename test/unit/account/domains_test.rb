require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Account::DomainsTest < ActiveSupport::TestCase
  test '#domain must be downcase' do
    account_one = FactoryBot.create(:simple_provider)
    account_one.subdomain = 'FOO'
    refute account_one.valid?
  end

  test '#domain must be unique' do
    account_one = FactoryBot.create(:simple_provider)

    ThreeScale.config.stubs(superdomain: 'example.com')
    account_two = Factory.build(:provider_account)
    account_two.domain = account_one.domain

    refute account_two.valid?
    assert account_two.errors[:subdomain].include? 'already taken'
  end

  test '#domain uniqueness ignores deleted' do
    account_one = FactoryBot.create(:simple_provider)

    ThreeScale.config.stubs(superdomain: 'example.com')
    account_two = Factory.build(:provider_account)
    account_two.domain = account_one.domain

    refute account_two.valid?
    assert account_two.errors[:subdomain].include? 'already taken'

    account_one.destroy

    assert account_two.valid?
  end

  test '#dedicated_domain returns nil if domain is set to a subdomain of the master domain' do
    account = Account.new(:provider_account => master_account,
                          :domain => "lol.#{master_account.superdomain}")
    assert_nil account.dedicated_domain
  end

  test 'domain is excluded from mass assignment ' do
    account = Account.new(:domain => 'api.example.net')
    assert_nil account.dedicated_domain
  end

  test '#superdomain returns the domain without www striped' do
    account = Account.new

    account.domain = 'www.example.net'
    assert_equal ThreeScale.config.superdomain, account.superdomain

    account.domain = 'example.net'
    assert_equal ThreeScale.config.superdomain, account.superdomain
  end

  test '#subdomain returns nil if domain is not set to a subdomain of the provider domain' do
    account = Account.new(:provider_account => master_account,
                          :domain => 'api.example.net')

    assert_nil account.subdomain
  end

  test 'find_by_domain! raises an exception if domain is blank' do
    assert_raise ActiveRecord::RecordNotFound do
      Account.find_by_domain!(nil)
    end
  end

  test 'find_by_domain! raises an exception if domain is blank even if there is an account with blank domain' do
    Account.create!(:org_name => 'foo', :domain => '')

    assert_raise ActiveRecord::RecordNotFound do
      Account.find_by_domain!(nil)
    end
  end

  test 'find_by_domain! finds account by domain' do
    account = Factory(:simple_account, :domain => 'example.net')
    assert_equal account, Account.find_by_domain!('example.net')
  end

  test '#generate_domains generates correctly default for provider' do
    account = Account.new(name: 'Provider Name') do |account|
      account.provider = true
      account.provider_account = master_account
    end
    account.generate_domains

    assert_equal 'provider-name',                                        account.subdomain
    assert_equal 'provider-name-admin',                                  account.self_subdomain
    assert_equal "provider-name.#{ThreeScale.config.superdomain}",       account.domain
    assert_equal "provider-name-admin.#{ThreeScale.config.superdomain}", account.self_domain
  end

  test '#generate_domains generates correctly custom for provider' do
    account = Account.new(name: 'Provider Name') do |account|
      account.provider = true
      account.subdomain = 'provider'
      account.provider_account = master_account
    end
    account.generate_domains

    assert_equal 'provider',                                        account.subdomain
    assert_equal 'provider-admin',                                  account.self_subdomain
    assert_equal "provider.#{ThreeScale.config.superdomain}",       account.domain
    assert_equal "provider-admin.#{ThreeScale.config.superdomain}", account.self_domain
  end

  test '#generate_domains generates correctly default for master' do
    account = Account.new(name: 'New Master Account') do |account|
      account.master = true
    end
    account.generate_domains

    assert_equal 'new-master-account',                                  account.subdomain
    assert_equal 'new-master-account',                                  account.self_subdomain
    assert_equal "new-master-account.#{ThreeScale.config.superdomain}", account.domain
    assert_equal "new-master-account.#{ThreeScale.config.superdomain}", account.self_domain
  end

  test '#generate_domains generates correctly custom for master' do
    account = Account.new(name: 'Master Account') do |account|
      account.subdomain = 'master'
      account.master = true
    end
    account.generate_domains

    assert_equal 'master',                                  account.subdomain
    assert_equal 'master',                                  account.self_subdomain
    assert_equal "master.#{ThreeScale.config.superdomain}", account.domain
    assert_equal "master.#{ThreeScale.config.superdomain}", account.self_domain
  end
end
