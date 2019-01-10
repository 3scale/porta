require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Account::SearchTest < ActiveSupport::TestCase
  test 'search without query returns all accounts by default, not using sphinx' do
    pending  = FactoryBot.create(:pending_account)
    approved = FactoryBot.create(:pending_account).tap(&:approve!)
    rejected = FactoryBot.create(:pending_account).tap(&:reject!)

    ThinkingSphinx::Search.expects(:new).never

    found = Account.scope_search({})
    assert_contains found, approved
    assert_contains found, pending
    assert_contains found, rejected
  end

  test 'search without query returns all account is state is "all", not using sphinx' do
    pending  = FactoryBot.create(:pending_account)
    approved = FactoryBot.create(:pending_account).tap(&:approve!)
    rejected = FactoryBot.create(:pending_account).tap(&:reject!)

    ThinkingSphinx::Search.expects(:new).never

    found = Account.scope_search(:state => 'all')
    assert_contains found, approved
    assert_contains found, pending
    assert_contains found, rejected
  end

  test 'search without query returns accounts by state if given, not using sphinx' do
    pending  = FactoryBot.create(:pending_account)
    approved = FactoryBot.create(:pending_account).tap(&:approve!)
    rejected = FactoryBot.create(:pending_account).tap(&:reject!)

    ThinkingSphinx::Search.expects(:new).never

    found = Account.scope_search(:state => 'pending')
    assert_contains         found, pending
    assert_does_not_contain found, approved
    assert_does_not_contain found, rejected
  end

  test 'search with query does a substring match' do
    Account.expects(:search_ids).with('foo').returns([])

    Account.scope_search(:query => 'foo')
  end

  test 'search with query on Account#buyer_accounts scopes to the provider account' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, :provider_account => provider)
    buyer2 = FactoryBot.create(:buyer_account)

    Account.expects(:search_ids).with('foo').returns([buyer.id, buyer2.id])

    buyers = provider.buyer_accounts.scope_search(:query => 'foo')

    assert_equal 1, buyers.count
    assert_equal buyer, buyers.first
  end

  test 'search_ids escapes the query' do
    assert_equal 'fo\/o', Account.search_ids('fo/o').query
  end

  test 'search_ids options' do
    ThinkingSphinx::Test.run do
      assert Account.buyers.search_ids('foo').populate
    end

    assert_equal({
                   ids_only: true, per_page: 1_000_000, star: true,
                   ignore_scopes: true, classes: [Account],
                   with: { }
                 }, Account.buyers.search_ids('foo').options)

    User.expects(:tenant_id).returns(42)

    assert_equal({
                   ids_only: true, per_page: 1_000_000, star: true,
                   ignore_scopes: true, classes: [Account],
                   with: { tenant_id: 42 }
                 }, Account.providers.search_ids('foo').options)
  end

  test 'search without query on Account#buyer_accounts scopes to the provider account' do
    provider_one = FactoryBot.create(:provider_account)
    buyer_one    = FactoryBot.create(:buyer_account, :provider_account => provider_one)

    provider_two = FactoryBot.create(:provider_account)
    buyer_two    = FactoryBot.create(:buyer_account, :provider_account => provider_two)

    ThinkingSphinx::Search.expects(:new).never

    found = provider_one.buyer_accounts.scope_search(:query=> '', :state => '')
    assert_contains         found, buyer_one
    assert_does_not_contain found, buyer_two
  end

  test 'user_key keyword search in the query' do
    application = FactoryBot.create(:cinstance, user_key: 'foobarkey')
    buyer = application.user_account
    provider = buyer.provider_account

    result = provider.buyer_accounts.scope_search(:query => 'user_key: foobarkey')

    assert_equal 1, result.size
    assert_contains result, buyer

    result = provider.buyer_accounts.scope_search(:query => 'user_key: wrongkey')
    assert_equal 0, result.size
  end

  # For mysterious reason, the thing didn't use to work when indifferent hash was passed in.
  test 'search without query works with options with indifferent access' do
    assert_nothing_raised do
      results = Account.search(nil, HashWithIndifferentAccess.new)
    end
  end

  test 'search with blank query does not use sphinx' do
    ThinkingSphinx::Search.expects(:new).never
    Account.scope_search(:query => '')
  end
end
