require 'test_helper'

class Backend::ModelExtensions::CinstanceTest < ActiveSupport::TestCase
  include ThreeScale
  include TestHelpers::BackendClientStubs

  test 'generates application_id when created' do
    cinstance = Cinstance.new(:plan         => FactoryBot.create(:application_plan),
                              :user_account => FactoryBot.create(:buyer_account))
    cinstance.save!

    assert_not_nil cinstance.application_id
  end

  test 'can be created with a custom application_id' do
    cinstance = Cinstance.new(:plan           => FactoryBot.create(:application_plan),
                              :user_account   => FactoryBot.create(:buyer_account))
    cinstance.application_id = 'custom_app_id'
    cinstance.save!

    assert_equal 'custom_app_id', cinstance.application_id
  end

  test 'application_id is immutable' do
    cinstance = FactoryBot.create(:simple_cinstance)

    assert_raise(ActiveRecord::ActiveRecordError) do
      cinstance.update_attribute :application_id, 'other_app_id'
    end
  end

  test 'application_id is unique for a tenant' do
    provider = FactoryBot.create(:provider_account)
    cinstance = Cinstance.new(:plan           => FactoryBot.create(:application_plan, :issuer => provider.default_service),
                              :user_account   => FactoryBot.create(:buyer_account))
    cinstance.application_id = 'custom_app_id'
    cinstance.save!
    assert_equal 'custom_app_id', cinstance.application_id

    invalid_cinstance = Cinstance.new(:plan => FactoryBot.create(:application_plan, :issuer => provider.default_service),
                                      :user_account => cinstance.user_account)
    invalid_cinstance.application_id = 'custom_app_id'
    assert !invalid_cinstance.valid?
    assert invalid_cinstance.errors[:application_id].include?("has already been taken")
  end

  test 'updates service data when provider cinstance changes user_key' do
    provider_account = FactoryBot.create(:provider_account)
    cinstance = provider_account.bought_cinstances.first

    ThreeScale::Core::Service.expects(:change_provider_key!).with(cinstance.user_key, anything)
    cinstance.change_user_key!
  end


  test 'stores backend application when cinstance is created' do
    provider_account = FactoryBot.create(:provider_account)
    service = provider_account.default_service
    plan = FactoryBot.create(:application_plan, :issuer => service)
    buyer_account = FactoryBot.create(:buyer_account, :provider_account => provider_account)

    cinstance = Cinstance.new(:plan => plan, :user_account => buyer_account)

    app_id = nil
    ThreeScale::Core::Application.expects(:save)
        .with(has_entries(service_id: service.backend_id,
                         plan_id: plan.id,
                         plan_name: plan.name,
                         state: :active)) do |params|
      app_id = params[:id]
    end

    cinstance.save!

    assert_equal cinstance.application_id, app_id
  end

  test 'updates backend application when cinstance changes state' do
    cinstance = FactoryBot.create(:cinstance)

    ThreeScale::Core::Application.expects(:save)
        .with(has_entries(service_id: cinstance.service.backend_id,
                         id: cinstance.application_id,
                         state: 'suspended'))

    cinstance.suspend!
  end

  test 'updates backend application when cinstance changes plan' do
    cinstance = FactoryBot.create(:cinstance)
    new_plan  = FactoryBot.create(:application_plan, :service => cinstance.service)
    cinstance.plan = new_plan

    ThreeScale::Core::Application.expects(:save)
        .with(has_entries(service_id: cinstance.service.backend_id,
                         id: cinstance.application_id,
                         plan_id: new_plan.id,
                         plan_name: new_plan.name))

    cinstance.save!
  end

  test 'creates user_key to application_id mapping when provider cinstance is created' do
    service_id = user_key = app_id = nil

    ThreeScale::Core::Application.expects(:save_id_by_key)
        .at_least_once.with do |*params|
      service_id, user_key, app_id = params
    end

    provider_account = FactoryBot.create(:provider_account)
    cinstance        = provider_account.bought_cinstance
    service          = Account.master.default_service

    assert_equal service.backend_id, service_id
    assert_equal cinstance.user_key, user_key
    assert_equal cinstance.application_id, app_id
  end

  test 'creates user_key to application_id mapping when buyer cinstance is created' do
    plan  = FactoryBot.create(:application_plan)
    buyer = FactoryBot.create(:buyer_account)

    user_key = app_id = nil

    ThreeScale::Core::Application.expects(:save_id_by_key)
        .with(plan.service.backend_id, anything, anything) do |*params|
      _, user_key, app_id = params
    end

    cinstance = Cinstance.create!(:plan => plan, :user_account => buyer)

    assert_equal cinstance.application_id, app_id
    assert_equal cinstance.user_key, user_key
  end

  test 'updates user_key to application_id mapping when cinstance changes user_key' do
    plan         = FactoryBot.create(:application_plan)
    buyer        = FactoryBot.create(:buyer_account)
    cinstance    = Cinstance.create!(:plan => plan, :user_account => buyer)
    old_user_key = cinstance.user_key

    ThreeScale::Core::Application.expects(:delete_id_by_key)
      .with(plan.service.backend_id, old_user_key)

    user_key = nil

    ThreeScale::Core::Application.expects(:save_id_by_key)
        .with(plan.service.backend_id, anything, cinstance.application_id) do |*params|
      _, user_key, _ = params
    end

    cinstance.change_user_key!

    assert_not_equal old_user_key, user_key
    assert_equal cinstance.user_key, user_key
  end

  # Regression test for https://github.com/3scale/system/issues/2033
  #
  test 'does not save empty user_key' do
    plan         = FactoryBot.create(:application_plan)
    buyer        = FactoryBot.create(:buyer_account)
    cinstance    = Cinstance.create!(:plan => plan, :user_account => buyer)
    old_user_key = cinstance.user_key

    ThreeScale::Core::Application.expects(:save_id_by_key).never
    ThreeScale::Core::Application.expects(:delete_id_by_key)
      .with(plan.service.backend_id, old_user_key)

    cinstance.update_attribute(:user_key, '')
  end
end
