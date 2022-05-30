# frozen_string_literal: true

require 'test_helper'

class PlanPresentersTest < ActiveSupport::TestCase
  attr_reader :service, :plans

  test '#plans sorted' do
    assert_same_elements plans.order(created_at: :desc), presenter({ sort: 'created_at', direction: 'desc' }).plans
  end

  test '#paginated_plans' do
    assert_same_elements plans[2, 2], presenter({ page: 2, per_page: 2 }).paginated_plans
  end

  test '#default_plan_select_data' do
    assert_same_elements [:plans, :"current-plan", :path], presenter.default_plan_select_data.keys # rubocop:disable Style/SymbolArray
  end

  test '#plans_table_data' do
    assert_same_elements [:columns, :plans, :count, :"search-href"], presenter.plans_table_data.keys # rubocop:disable Style/SymbolArray
  end

  class Api::ApplicationPlansPresenterTest < PlanPresentersTest
    def setup
      @service = FactoryBot.create(:service)
      FactoryBot.create_list(:application_plan, 5, issuer: service)

      @plans = @service.application_plans
    end

    def presenter(params = {})
      Api::ApplicationPlansPresenter.new(service: service, collection: plans, params: params.reverse_merge({ sort: 'name', direction: 'asc' }))
    end
  end

  class Api::ServicePlansPresenterTest < PlanPresentersTest
    def setup
      provider = FactoryBot.create(:simple_provider)
      @service = FactoryBot.create(:service, account: provider)
      FactoryBot.create_list(:service_plan, 5, service: service)

      @plans = provider.service_plans
    end

    def presenter(params = {})
      Api::ServicePlansPresenter.new(service: service, collection: plans, params: params.reverse_merge({ sort: 'name', direction: 'asc' }))
    end
  end

  class Buyers::AccountPlansPresenterTest < PlanPresentersTest
    def setup
      provider = FactoryBot.create(:simple_provider)
      FactoryBot.create_list(:account_plan, 5, provider: provider)

      @plans = provider.account_plans
    end

    def presenter(params = {})
      Buyers::AccountPlansPresenter.new(collection: plans, params: params.reverse_merge({ sort: 'name', direction: 'asc' }))
    end
  end

  def self.runnable_methods
    PlanPresentersTest == self ? [] : super
  end
end
