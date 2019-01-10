require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Authentication::Strategy::InternalTest < ActiveSupport::TestCase
  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @strategy = Authentication::Strategy::Internal.new(@provider_account)
  end

  test '#track_signup_options' do
    assert_equal({strategy: 'credentials'}, @strategy.track_signup_options)
  end

  test 'template' do
    assert_equal 'sessions/strategies/internal', @strategy.template
  end

  test 'authenticate authenticates buyer user' do
    buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    buyer_user          = FactoryBot.create(:user, :account  => buyer_account, :password => 'kangaroo')
    buyer_user.activate!

    user = FactoryBot.create(:user, :account  => @provider_account,
                          :username => 'dave',
                          :password => 'kangaroo')
    user.activate!

    assert_equal buyer_user, @strategy.authenticate(:username => buyer_user.username,
                                                    :password => 'kangaroo')

    assert_nil @strategy.authenticate(:username => 'dave', :password => 'kangaroo')
  end

  test 'authenticate returns nil if the password is incorrect' do
    user = FactoryBot.create(:user, :account => @provider_account, :password => 'foobar')
    user.activate!

    assert_nil @strategy.authenticate(:username => user.username, :password => 'wrong!')
  end

  test 'authenticate returns nil if the user is pending' do
    user = FactoryBot.create(:user, :account => @provider_account, :password => 'foobar')
    assert_nil @strategy.authenticate(:username => user.username,
                                      :password => 'foobar')
  end

  test 'authenticate returns nil if the user is suspended' do
    user = FactoryBot.create(:user, :password => 'foobar')
    user.activate!
    user.suspend!

    assert_nil @strategy.authenticate(:username => user.username,
                                      :password => 'foobar')
  end

  test 'authenticate authenticates user by username in buyer side' do
    buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    user          = FactoryBot.create(:user, :account  => buyer_account, :password => 'kangaroo')

    user.activate!

    assert_equal user, @strategy.authenticate(:username => user.username,
                                              :password => 'kangaroo')
  end


  test 'authenticate authenticates user by email in buyer domain' do
    buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    user          = FactoryBot.create(:user, :account  => buyer_account, :password => 'kangaroo')
    user.activate!

    assert_equal user, @strategy.authenticate(:username => user.email,
                                              :password => 'kangaroo')
  end

  test 'authenticate returns nil if the account of the user is pending' do
    account = FactoryBot.create(:account, :provider_account => @provider_account)
    user    = FactoryBot.create(:user, :account => account, :password => 'foobar')

    user.activate!
    account.make_pending!

    assert_nil @strategy.authenticate(:username => user.username,
                                      :password => 'foobar')
  end

  test 'authenticate returns nil if the account of the user is rejected' do
    account = FactoryBot.create(:account, :provider_account => @provider_account)
    user    = FactoryBot.create(:user, :account => account, :password => 'foobar')

    user.activate!
    account.reject!

    assert_nil @strategy.authenticate(:username => user.username,
                                      :password => 'foobar')
  end

  test 'authenticate authenticates user with approved account' do
    account = FactoryBot.create(:account, :provider_account => @provider_account)
    user    = FactoryBot.create(:user, :account => account, :password => 'foobar')

    user.activate!

    assert_equal user, @strategy.authenticate(:username => user.username,
                                              :password => 'foobar')
  end

  test 'authenticates provider side' do
    provider_strategy = Authentication::Strategy::Internal.new(@provider_account, true)
    user = FactoryBot.create(:user, :account  => @provider_account,
                          :username => 'dave',
                          :password => 'kangaroo')

    account = FactoryBot.create(:account, :provider_account => @provider_account)
    buyer_pass = 'foobar'
    buyer_user    = FactoryBot.create(:user, :account => account, :password => buyer_pass)

    user.activate!
    buyer_user.activate!

    assert_equal user, provider_strategy.authenticate(:username => 'dave', :password => 'kangaroo')
    assert_nil provider_strategy.authenticate(:username => buyer_user.username, :password => buyer_pass)
  end

end
