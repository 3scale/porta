# frozen_string_literal: true

require 'test_helper'

class PlanPresentersTest < ActiveSupport::TestCase
  test '#paginated_table_plans can be ordered' do
    assert_equal plans.reorder(name: :desc), presenter({ sort: 'name', direction: 'desc' }).paginated_table_plans
    assert_equal plans.reorder(name: :asc), presenter({ sort: 'name', direction: 'asc' }).paginated_table_plans

    assert_equal plans.reorder(contracts_count: :desc, name: :asc), presenter({ sort: 'contracts_count', direction: 'desc' }).paginated_table_plans
    assert_equal plans.reorder(contracts_count: :asc, name: :asc), presenter({ sort: 'contracts_count', direction: 'asc' }).paginated_table_plans

    assert_equal plans.reorder(state: :desc, name: :asc), presenter({ sort: 'state', direction: 'desc' }).paginated_table_plans
    assert_equal plans.reorder(state: :asc, name: :asc), presenter({ sort: 'state', direction: 'asc' }).paginated_table_plans
  end

  test 'default plan select plans have a fixed order by name' do
    data = presenter({ sort: 'name', direction: 'desc' }).default_plan_select_data
    ids = data[:plans].map { |n| n['id'] }
    assert_equal plans.reorder(name: :asc).pluck(:id), ids
  end

  test '#paginated_table_plans can have pagination' do
    assert_equal plans[2, 2], presenter({ page: 2, per_page: 2 }).paginated_table_plans
  end

  test '#default_plan_select_data' do
    assert_equal %i[plans initialDefaultPlan path], presenter.default_plan_select_data.keys
  end

  test '#plans_table_data' do
    assert_equal %i[createButton columns plans count], presenter.plans_table_data.keys
  end

  class Api::ApplicationPlansPresenterTest < PlanPresentersTest
    def setup
      provider = FactoryBot.create(:simple_provider)
      @service = FactoryBot.create(:service, account: provider)
      FactoryBot.create_list(:application_plan, 5, issuer: service)
      @user = FactoryBot.create(:simple_user, account: provider)

      @plans = @service.application_plans
                       .reorder(name: :asc)
    end

    test '#paginated_table_plans can search' do
      FactoryBot.create(:application_plan, issuer: service, name: 'Basic')

      result = plans.where({ name: 'Basic' })
      empty_result = plans.where({ name: 'Foo' })

      ApplicationPlan.expects(:scope_search).returns(result).once
      assert_equal result, presenter({ search: 'Basic' }).paginated_table_plans

      ApplicationPlan.expects(:scope_search).returns(empty_result).once
      assert_equal empty_result, presenter({ search: 'Foo' }).paginated_table_plans
    end

    def presenter(params = {})
      Api::ApplicationPlansPresenter.new(service: service, params: params, user: user)
    end
  end

  class Api::ServicePlansPresenterTest < PlanPresentersTest
    def setup
      provider = FactoryBot.create(:simple_provider)
      @service = FactoryBot.create(:service, account: provider)
      FactoryBot.create_list(:service_plan, 5, service: service)
      @user = FactoryBot.create(:simple_user, account: provider)

      @plans = provider.service_plans
                       .reorder(name: :asc)
    end

    test '#paginated_table_plans can search' do
      FactoryBot.create(:service_plan, issuer: service, name: 'Basic')

      result = plans.where({ name: 'Basic' })
      empty_result = plans.where({ name: 'Foo' })

      ServicePlan.expects(:scope_search).returns(result).once
      assert_equal result, presenter({ search: 'Basic' }).paginated_table_plans

      ServicePlan.expects(:scope_search).returns(empty_result).once
      assert_equal empty_result, presenter({ search: 'Foo' }).paginated_table_plans
    end

    def presenter(params = {})
      Api::ServicePlansPresenter.new(service: service, params: params, user: user)
    end
  end

  class Buyers::AccountPlansPresenterTest < PlanPresentersTest
    attr_reader :provider

    def setup
      @provider = FactoryBot.create(:simple_provider)
      FactoryBot.create_list(:account_plan, 5, provider: provider)
      @user = FactoryBot.create(:simple_user, account: provider)

      @plans = provider.account_plans
                        .reorder(name: :asc)
    end

    test '#paginated_table_plans can search' do
      FactoryBot.create(:account_plan, provider: provider, name: 'Basic')

      result = plans.where({name: 'Basic' })
      empty_result = plans.where({name: 'Foo' })

      AccountPlan.expects(:scope_search).returns(result).once
      assert_equal result, presenter({ search: 'Basic' }).paginated_table_plans

      AccountPlan.expects(:scope_search).returns(empty_result).once
      assert_equal empty_result, presenter({ search: 'Foo' }).paginated_table_plans
    end

    def presenter(params = {})
      Buyers::AccountPlansPresenter.new(collection: plans, params: params, user: user)
    end
  end

  def self.runnable_methods
    PlanPresentersTest == self ? [] : super
  end

  private

  attr_reader :service, :plans, :user
end
