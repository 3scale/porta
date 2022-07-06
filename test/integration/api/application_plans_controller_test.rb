# frozen_string_literal: true

require 'test_helper'

class Api::ApplicationPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    login! current_account
    @service = current_account.first_service!
  end

  attr_reader :service, :plan

  class MasterAdminTest < self
    setup do
      @plan = service.default_application_plan
    end

    test 'index' do
      get admin_service_application_plans_path(service)
      assert_response :success

      ThreeScale.stubs(master_on_premises?: true)
      get admin_service_application_plans_path(service)
      assert_response :forbidden
    end

    test 'new' do
      get new_admin_service_application_plan_path(service)
      assert_response :success

      ThreeScale.stubs(master_on_premises?: true)
      get new_admin_service_application_plan_path(service)
      assert_response :forbidden
    end

    test 'create' do
      assert_difference @service.application_plans.method(:count) do
        post admin_service_application_plans_path(service), params: application_plan_params
        assert_response :redirect
        assert_equal "Created Application plan #{application_plan[:name]}", flash[:notice]
      end

      app = service.reload.application_plans.last
      assert_equal app.name, application_plan[:name]
      assert_equal app.system_name, application_plan[:system_name]
      assert_not app.approval_required
      assert_equal app.trial_period_days, application_plan[:trial_period_days]
      assert_equal app.setup_fee, ThreeScale::Money.new(application_plan[:setup_fee], 'EUR')
      assert_equal app.cost_per_month, ThreeScale::Money.new(application_plan[:cost_per_month], 'EUR')

      ThreeScale.stubs(master_on_premises?: true)
      assert_no_difference @service.application_plans.method(:count) do
        post admin_service_application_plans_path(service), params: application_plan_params
        assert_response :forbidden
      end
    end

    test 'destroy' do
      plan = FactoryBot.create(:application_plan, service: @service)
      assert_difference( @service.application_plans.method(:count), -1 ) do
        delete polymorphic_path([:admin, plan], format: :json)
        assert_response :success
        assert_equal 'The plan was deleted', (JSON.parse response.body)['notice']
      end
      assert_raise ActiveRecord::RecordNotFound do
        plan.reload
      end

      ThreeScale.stubs(master_on_premises?: true)
      plan = FactoryBot.create(:application_plan, service: @service)
      assert_no_difference @service.application_plans.method(:count) do
        delete polymorphic_path([:admin, plan])
        assert_response :forbidden
        assert plan.reload
      end
    end

    test 'GET index shows the create button for Saas' do
      # Saas is the default
      get admin_service_application_plans_path(service)
      assert_xpath "//a[contains(@href, '#{new_admin_service_application_plan_path(service)}')]", 'Create Application plan'
    end

    test 'index pagination does not count custom plans' do
      get admin_service_application_plans_path(service)
      table = Nokogiri::HTML.parse(response.body).xpath "//*[@id='plans_table']"

      pagination_count = JSON.parse table.attribute('data-count')
      table_count = JSON.parse(table.attribute('data-plans').value).length

      assert_equal pagination_count, table_count
    end

    test 'actions are authorized for Saas' do
      get admin_service_application_plans_path(service)
      assert_response :ok

      get new_admin_service_application_plan_path(service)
      assert_response :ok

      post admin_service_application_plans_path(service), params: { application_plan:{ name: 'planName' } }
      assert_response :redirect

      post hide_admin_plan_path(plan, format: :json)
      assert_response :ok

      post publish_admin_plan_path(plan, format: :json)
      assert_response :ok

      post admin_plan_copies_path(plan_id: plan.id, format: :json)
      assert_response :created

      delete admin_application_plan_path(plan)
      assert_response :redirect
    end

    test 'actions are not authorized for on-prem' do
      ThreeScale.config.stubs(onpremises: true)
      ThreeScale.stubs(master_on_premises?: true)

      get admin_service_application_plans_path(service)
      assert_response :forbidden

      get new_admin_service_application_plan_path(service)
      assert_response :forbidden

      post admin_service_application_plans_path(service), params: { application_plan:{ name: 'planName' } }
      assert_response :forbidden

      post hide_admin_plan_path(plan, format: :json)
      assert_response :forbidden

      post publish_admin_plan_path(plan, format: :json)
      assert_response :forbidden

      post admin_plan_copies_path(plan_id: plan.id, format: :json)
      assert_response :forbidden

      delete admin_application_plan_path(plan, format: :json)
      assert_response :forbidden
    end

    private

    def current_account
      master_account
    end
  end

  class ProviderAdminTest < self
    setup do
      @plan = FactoryBot.create(:application_plan, issuer: service)
    end

    test 'index' do
      get admin_service_application_plans_path(service)
      assert_response :success
    end

    test 'new' do
      get new_admin_service_application_plan_path(service)
      assert_response :success
    end

    test 'create' do
      assert_difference service.application_plans.method(:count) do
        post admin_service_application_plans_path(service), params: application_plan_params
        assert_response :redirect
        assert_equal "Created Application plan #{application_plan[:name]}", flash[:notice]
      end
    end

    test 'destroy' do
      delete polymorphic_path([:admin, plan], format: :json)
      assert_response :success
      assert_equal 'The plan was deleted', (JSON.parse response.body)['notice']
    end

    test 'plan cannot be deleted because of having contracts' do
      plan.create_contract_with(FactoryBot.create(:buyer_account))
      delete polymorphic_path([:admin, plan])
      assert_response :redirect
      assert_equal error_message(:has_contracts), flash[:error]
    end

    test 'plan cannot be deleted because of customizations' do
      customization = FactoryBot.create(:application_plan, original_id: plan.id)
      customization.create_contract_with(FactoryBot.create(:buyer_account))
      delete polymorphic_path([:admin, plan])
      assert_response :redirect
      assert_equal error_message(:customizations_has_contracts), flash[:error]
    end

    test 'GET index shows the create button indepently of the onpremises value' do
      [true, false].each do |onpremises|
        ThreeScale.config.stubs(onpremises: onpremises)
        get admin_service_application_plans_path(service)
        assert_xpath("//a[contains(@href, '#{new_admin_service_application_plan_path(service)}')]", 'Create Application plan')
      end
    end

    test 'Actions are always authorized' do
      [true, false].each do |onpremises|
        @plan = FactoryBot.create(:application_plan, issuer: @service)
        ThreeScale.config.stubs(onpremises: onpremises)

        get new_admin_service_application_plan_path(service)
        assert_response :ok

        get new_admin_service_application_plan_path(service)
        assert_response :ok

        post admin_service_application_plans_path(service), params: { application_plan:{ name: "planName #{onpremises ? 'onprem' : 'saas'}" } }
        assert_response :redirect

        post publish_admin_plan_path(plan, format: :json)
        assert_response :ok

        post hide_admin_plan_path(plan, format: :json)
        assert_response :ok

        post admin_plan_copies_path(plan_id: plan.id, format: :json)
        assert_response :created

        delete polymorphic_path([:admin, plan], format: :json)
        assert_response :ok
      end
    end

    private

    def current_account
      @current_account ||= FactoryBot.create(:provider_account)
    end
  end

  class ProviderMemberTest < self
    setup do
      @plan = FactoryBot.create(:application_plan, issuer: service)
      @member = FactoryBot.create(:member, account: current_account)
      member.activate!
      logout! && login!(current_account, user: member)
    end

    attr_reader :member

    test 'member without permission' do
      get admin_service_application_plans_path(service)
      assert_response :forbidden

      get new_admin_service_application_plan_path(service)
      assert_response :forbidden

      post admin_service_application_plans_path(service), params: { application_plan:{ name: 'planName' } }
      assert_response :forbidden

      get edit_admin_application_plan_path(plan)
      assert_response :forbidden

      put admin_application_plan_path(plan), params: { application_plan:{ name: 'New plan name' } }
      assert_response :forbidden

      post masterize_admin_service_application_plans_path(service)
      assert_response :forbidden

      post publish_admin_plan_path(plan, format: :json)
      assert_response :forbidden

      post hide_admin_plan_path(plan, format: :json)
      assert_response :forbidden

      post admin_plan_copies_path(plan_id: plan.id, format: :json)
      assert_response :forbidden

      delete admin_application_plan_path(plan, format: :json)
      assert_response :forbidden
    end

    test 'member with permission' do
      member.admin_sections = %w[plans]
      member.save!

      get admin_service_application_plans_path(service)
      assert_response :success

      get new_admin_service_application_plan_path(service)
      assert_response :success

      post admin_service_application_plans_path(service), params: { application_plan:{ name: 'planName' } }
      assert_response :redirect

      get edit_admin_application_plan_path(plan)
      assert_response :success

      put admin_application_plan_path(plan), params: { application_plan:{ name: 'New plan name' } }
      assert_response :redirect

      post masterize_admin_service_application_plans_path(service)
      assert_response :redirect
      assert_nil service.reload.default_application_plan

      post masterize_admin_service_application_plans_path(service, params: { id: @plan.id })
      assert_response :redirect
      assert_equal @plan, service.reload.default_application_plan

      post publish_admin_plan_path(plan, format: :json)
      assert_response :ok

      post hide_admin_plan_path(plan, format: :json)
      assert_response :ok

      post admin_plan_copies_path(plan_id: plan.id, format: :json)
      assert_response :created

      delete admin_application_plan_path(plan, format: :json)
      assert_response :ok
    end

    test 'member with permission over restricted services' do
      forbidden_service = FactoryBot.create(:simple_service, account: current_account)
      forbidden_plan = FactoryBot.create(:application_plan, issuer: forbidden_service)

      member.admin_sections = %w[plans]
      member.member_permission_service_ids = [service.id]
      member.save!

      get admin_service_application_plans_path(service)
      assert_response :success

      # This is testing presenter logic, not integration. Test body response. Use Nokogiri::HTML::Document.parse(response.body)
      plans = assigns(:presenter).plans
      assert_same_elements service.application_plans, plans
      assert_not_includes plans, forbidden_plan

      get new_admin_service_application_plan_path(service)
      assert_response :success

      post admin_service_application_plans_path(service), params: { application_plan: { name: 'planName' } }
      assert_response :redirect

      get edit_admin_application_plan_path(plan)
      assert_response :success

      put admin_application_plan_path(plan), params: { application_plan: { name: 'New plan name' } }
      assert_response :redirect

      post masterize_admin_service_application_plans_path(service)
      assert_response :redirect
      assert_nil service.reload.default_application_plan

      post masterize_admin_service_application_plans_path(service, params: { id: @plan.id })
      assert_response :redirect
      assert_equal @plan, service.reload.default_application_plan

      post publish_admin_plan_path(plan, format: :json)
      assert_response :ok

      post hide_admin_plan_path(plan, format: :json)
      assert_response :ok

      post admin_plan_copies_path(plan_id: plan.id, format: :json)
      assert_response :created

      delete admin_application_plan_path(plan, format: :json)
      assert_response :success

      get admin_service_application_plans_path(forbidden_service)
      assert_response :not_found

      get new_admin_service_application_plan_path(forbidden_service)
      assert_response :not_found

      post admin_service_application_plans_path(forbidden_service), params: { application_plan:{ name: 'planName' } }
      assert_response :not_found

      get edit_admin_application_plan_path(forbidden_plan)
      assert_response :not_found

      put admin_application_plan_path(forbidden_plan), params: { application_plan:{ name: 'New plan name' } }
      assert_response :not_found

      post masterize_admin_service_application_plans_path(forbidden_service)
      assert_response :not_found

      post hide_admin_plan_path(forbidden_plan, format: :json)
      assert_response :not_found

      post publish_admin_plan_path(forbidden_plan, format: :json)
      assert_response :not_found

      post admin_plan_copies_path(plan_id: forbidden_plan.id, format: :json)
      assert_response :not_found

      delete admin_application_plan_path(forbidden_plan, format: :json)
      assert_response :not_found
    end

    private

    def current_account
      @current_account ||= FactoryBot.create(:provider_account)
    end
  end

  protected

  def application_plan_params
    { service_id: service.id, application_plan: application_plan }
  end

  def application_plan
    { name: 'Plan name', system_name: 'system_name', approval_required: 0, trial_period_days: 2, setup_fee: 10.5, cost_per_month: 2.5 }
  end

  def error_message(key)
    I18n.t("activerecord.errors.models.application_plan.#{key}")
  end
end
