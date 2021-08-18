require 'test_helper'

class Account::SearchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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

  test 'search with query by email' do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        provider = FactoryBot.create(:simple_provider)
        buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: provider)
        ['foo@bar.co.example.com', 'foo@example.org'].each_with_index do |email, buyer_index|
          FactoryBot.create(:admin, account: buyers[buyer_index], email: email)
        end

        buyers = provider.buyer_accounts.scope_search(:query => 'foo@bar.co.example.com')
        expected_buyer = User.find_by!(email: 'foo@bar.co.example.com').account
        assert_equal [expected_buyer], buyers
      end
    end
  end

  test 'search_ids options' do
    ThinkingSphinx::Test.rt_run do
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

  test 'search user_key without keyword with many records is always indexed and found' do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        service = FactoryBot.create(:simple_service)
        buyer = FactoryBot.create(:simple_buyer)
        FactoryBot.create_list(:application_plan, 5, issuer: service).each_with_index do |plan, index|
          contract = plan.create_contract_with!(buyer)
          contract.update!(user_key: (index.to_s * 256))
        end

        buyer.bought_cinstances.pluck(:user_key).each do |user_key|
          assert_equal [buyer.id], Account.scope_search(query: user_key).pluck(:id)
        end
      end
    end
  end

  # For mysterious reason, the thing didn't use to work when indifferent hash was passed in.
  test 'search without query works with options with indifferent access' do
    assert_nothing_raised do
      results = Account.search(nil, ActiveSupport::HashWithIndifferentAccess.new)
    end
  end

  test 'search with blank query does not use sphinx' do
    ThinkingSphinx::Search.expects(:new).never
    Account.scope_search(:query => '')
  end

  test 'by_created_within' do
    ThinkingSphinx::Search.expects(:new).never
    provider = FactoryBot.create(:simple_provider)
    assert_equal 0, provider.buyers.count
    buyers = FactoryBot.create_list(:buyer_account, 3, provider_account: provider, created_at: Time.parse('2019-01-10') )
    buyers.first.update_attribute(:created_at, '2019-02-10'.to_time)
    result = provider.buyers.scope_search(created_within: ['2019-01-01', '2019-01-31'])
    assert_equal 2, result.size
  end
end
