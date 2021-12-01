# frozen_string_literal: true

require 'test_helper'

class ThreeScale::SearchTest < ActiveSupport::TestCase
  class FakeModelTest < ActiveSupport::TestCase
    class Model < ApplicationRecord
      self.table_name = 'accounts'

      include ThreeScale::Search::Scopes

      scope :by_fancy_scope, ->(value) { where(id: value == '1') }
      scope :by_another_scope, -> { where(created_at: :column) }
    end

    teardown do
      Model.allowed_sort_columns = []
      Model.allowed_search_scopes = []
      Model.default_search_scopes = []
      Model.sort_columns_joins = {}
    end

    test "should have right methods" do
      assert Model.respond_to?(:scope_search)
      assert Model.respond_to?(:order_by)
    end

    test "should search with non allowed scope" do
      assert_equal(Model.all, Model.scope_search(:another_scope => "dl"))
    end

    test "should search with allowed scope" do
      Model.allowed_search_scopes = ['fancy_scope']
      assert_equal(Model.by_fancy_scope('1'), Model.scope_search(:fancy_scope => "1") )
    end

    test "should have default scope" do
      Model.allowed_search_scopes = ['fancy_scope']
      Model.default_search_scopes = %w[fancy_scope another_scope]

      scope = Model.by_another_scope.by_fancy_scope('1')
      assert_equal(scope, Model.scope_search(:fancy_scope => "1"))
    end

    test "should order by allowed column with full table name" do
      Model.allowed_sort_columns =  ['created_at']

      scope = Model.order('accounts.created_at DESC')
      assert_equal scope, Model.order_by(:created_at, :desc)
    end

    test "should order by non allowed column" do
      assert_equal Model.all, Model.order_by(:unknown, :desc)
    end
  end

  test "Search object should reject blank values" do
    search = ThreeScale::Search.new :blank => '', :present => 'present'
    assert_nil search.blank
    assert 'present', search.present
  end

  test "can search ServiceContract by service_id and plan_id same time" do
    FactoryBot.create(:service_plan)
    service_plan = FactoryBot.create(:service_plan)
    service = service_plan.service
    service_contract = FactoryBot.create(:service_contract, :plan => service_plan)
    query = { "account_query"=>"", "deleted_accounts"=>"0", "service_id"=>service.id, "plan_type"=>"", "plan_id"=>"", "state"=>"" }
    ThreeScale::Search.new(query)
    assert_equal [service_contract], ServiceContract.scope_search(query).order_by(nil)
    assert_equal [service_contract], service.account.provided_service_contracts.scope_search(query)
  end

  test "Alert should sort by timestmap" do
    alert_one = FactoryBot.create(:limit_alert)
    alert_two = FactoryBot.create(:limit_alert)
    assert_equal [alert_one, alert_two], Alert.order_by(:timestamp, :asc)
  end

  test "Alert should sort by timestamp and retain next scope" do
    assert_equal(Alert.preload(:account).order("alerts.timestamp DESC"), Alert.preload(:account).order_by(:timestamp))
  end

  test "Cinstance should retain previous scope on search" do
    abc = FactoryBot.create(:cinstance, :user_key => "abc")
    bcd = FactoryBot.create(:cinstance, :user_key => "bcd")

    assert_equal [abc], Cinstance.by_user_key("abc").scope_search(:user_key => 'abc')
    assert_equal [bcd], Cinstance.by_user_key("bcd").scope_search(:user_key => 'bcd')
    assert_equal [], Cinstance.by_user_key('abc').scope_search(:user_key => 'bcd')
  end

  test "Cinstance should order and search" do
    account = FactoryBot.create(:account)

    abc = FactoryBot.create(:cinstance, name: "abc", user_account: account)
    bcd = FactoryBot.create(:cinstance, name: "bcd", user_account: account)
    cde = FactoryBot.create(:cinstance, name: "cde", user_account: account)

    options = {:account => account.id}
    array = [abc, bcd, cde]

    assert_equal array, Cinstance.order_by(:name, :asc).scope_search(options).to_a
    assert_equal array.reverse, Cinstance.order_by(:name, :desc).scope_search(options).to_a
    assert_equal array, Cinstance.scope_search(options).order_by(:name, :asc)
    assert_equal array.reverse, Cinstance.scope_search(options).order_by(:name, :desc)
  end

  test "Cinstance should work with all scopes" do
    app = FactoryBot.create(:cinstance, name: "test")
    plan = app.plan

    options = {:account => app.user_account_id, :deleted_accounts => true, :plan_type => "free", :plan_id => plan.id, :type => "Cinstance"}

    assert_equal [app], Cinstance.order_by(:name).scope_search(options)
  end

  test "ServiceContract should not depend on parameters order" do
    FactoryBot.create(:service_contract)
    sc2 = FactoryBot.create(:service_contract)

    plan2 = sc2.plan
    plan2.update(setup_fee: 30)

    assert plan2.paid?

    assert_equal ServiceContract.scope_search(:plan_id => sc2.plan_id, :plan_type => :paid),
                 ServiceContract.scope_search(:plan_type => :paid, :plan_id => sc2.plan_id)

    assert_equal ServiceContract.scope_search(:plan_id => sc2.plan_id, :plan_type => :free),
                 ServiceContract.scope_search(:plan_type => :free, :plan_id => sc2.plan_id)
  end

  test "Account should order by country name" do
    it = FactoryBot.create(:country, code: "IT", name: "Italy")
    zb = FactoryBot.create(:country, code: "ZB", name: "Zimbabwe")

    provider = FactoryBot.create(:provider_account)

    buyer_it = FactoryBot.create(:buyer_account, provider_account: provider, country: it)
    buyer_zb = FactoryBot.create(:buyer_account, provider_account: provider, country: zb)

    assert_equal [buyer_it, buyer_zb], provider.buyer_accounts.order_by('countries.name', :asc)
  end

  class FooClass < ApplicationController
    include ThreeScale::Search::Helpers
    def params
      {per_page: 100}
    end
  end

  test 'per_page should be minus or equal that MAX_PER_PAGE' do
    pagination_params = FooClass.new.send(:pagination_params)
    assert_equal ThreeScale::Search::Helpers::MAX_PER_PAGE, pagination_params[:per_page]
  end
end
