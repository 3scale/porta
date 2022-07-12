# frozen_string_literal: true

require 'test_helper'

class PlanPresentersTest < ActiveSupport::TestCase
  attr_reader :service, :plans, :provider

  test '#paginated_table_plans can be ordered' do
    assert_equal plans.reorder(name: :desc), presenter({sort: 'name', direction: 'desc'}).paginated_table_plans
  end

  test '#paginated_table_plans can have pagination' do 
    assert_equal plans[2, 2], presenter({ page: 2, per_page: 2 }).paginated_table_plans
  end

  test '#default_plan_select_data' do
    assert_equal [:plans, :"current-plan", :path], presenter.default_plan_select_data.keys # rubocop:disable Style/SymbolArray
  end

  test '#plans_table_data' do
    assert_equal [:columns, :plans, :count, :"search-href"], presenter.plans_table_data.keys # rubocop:disable Style/SymbolArray
  end

  class Api::ApplicationPlansPresenterTest < PlanPresentersTest
    def setup
      @service = FactoryBot.create(:service)
      FactoryBot.create_list(:application_plan, 5, issuer: service)
      
      @plans = @service.application_plans
                       .order(name: :asc)
    end
    
    test '#paginated_table_plans can search' do 
      FactoryBot.create(:application_plan, issuer: service, name: 'Basic')
      
      result = plans.where({name: 'Basic'})
      empty_result = plans.where({name: 'Foo'})

      ApplicationPlan.expects(:scope_search).returns(result).once
      assert_equal result, presenter({ search: 'Basic'}).paginated_table_plans

      ApplicationPlan.expects(:scope_search).returns(empty_result).once
      assert_equal empty_result, presenter({ search: 'Foo'}).paginated_table_plans
    end

    def presenter(params = {})
      Api::ApplicationPlansPresenter.new(service: service, collection: plans, params: params)
    end
  end

  class Api::ServicePlansPresenterTest < PlanPresentersTest
    def setup
      provider = FactoryBot.create(:simple_provider)
      @service = FactoryBot.create(:service, account: provider)
      FactoryBot.create_list(:service_plan, 5, service: service)
      
      
      @plans = provider.service_plans
                       .reorder(name: :asc)
    end
    
    test '#paginated_table_plans can search' do 
      FactoryBot.create(:service_plan, issuer: service, name: 'Basic')
            
      result = plans.where({name: 'Basic'})
      empty_result = plans.where({name: 'Foo'})
      
      ServicePlan.expects(:scope_search).returns(result).once
      assert_equal result, presenter({ search: 'Basic'}).paginated_table_plans
      
      ServicePlan.expects(:scope_search).returns(empty_result).once
      assert_equal empty_result, presenter({ search: 'Foo'}).paginated_table_plans
    end

    def presenter(params = {})
      Api::ServicePlansPresenter.new(service: service, collection: plans, params: params)
    end
  end

  class Buyers::AccountPlansPresenterTest < PlanPresentersTest
    def setup
      @provider = FactoryBot.create(:simple_provider)
      FactoryBot.create_list(:account_plan, 5, provider: provider)
      
      @plans = provider.account_plans
                        .order(name: :asc)
    end
    
    test '#paginated_table_plans can search' do 
      FactoryBot.create(:account_plan, provider: provider, name: 'Basic')
      
      result = plans.where({name: 'Basic'})
      empty_result = plans.where({name: 'Foo'})

      AccountPlan.expects(:scope_search).returns(result).once
      assert_equal result, presenter({ search: 'Basic'}).paginated_table_plans

      AccountPlan.expects(:scope_search).returns(empty_result).once
      assert_equal empty_result, presenter({ search: 'Foo'}).paginated_table_plans
    end

    def presenter(params = {})
      Buyers::AccountPlansPresenter.new(collection: plans, params: params)
    end
  end

  def self.runnable_methods
    PlanPresentersTest == self ? [] : super
  end
end
