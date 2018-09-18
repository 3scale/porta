require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Backend::ModelExtensions::CinstanceTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  include ThreeScale
  include TestHelpers::BackendClientStubs

  test 'generates application_id when created' do
    cinstance = Cinstance.new(:plan         => Factory(:application_plan),
                              :user_account => Factory(:buyer_account))
    cinstance.save!

    assert_not_nil cinstance.application_id
  end

  test 'can be created with a custom application_id' do
    cinstance = Cinstance.new(:plan           => Factory(:application_plan),
                              :user_account   => Factory(:buyer_account))
    cinstance.application_id = 'custom_app_id'
    cinstance.save!

    assert_equal 'custom_app_id', cinstance.application_id
  end

  test 'application_id is properly validated' do
    cinstance = Cinstance.new(:plan => Factory(:application_plan), :user_account   => Factory(:buyer_account))

    cinstance.application_id = "1"
    assert !cinstance.valid?

    cinstance.application_id = "asd"
    assert !cinstance.valid?

    cinstance.application_id = "6f76704d-14fc-40ab-bd2a-1a1442dc6b91"
    assert cinstance.valid?

    cinstance.application_id = "sdfsd-*"
    assert !cinstance.valid?

    cinstance.application_id = "valid"
    assert cinstance.valid?
  end

  test 'application_id is immutable' do
    cinstance = Factory(:simple_cinstance)

    assert_raise(ActiveRecord::ActiveRecordError) do
      cinstance.update_attribute :application_id, 'other_app_id'
    end
  end

  test 'application_id is unique for a tenant' do
    provider = Factory(:provider_account)
    cinstance = Cinstance.new(:plan           => Factory(:application_plan, :issuer => provider.default_service),
                              :user_account   => Factory(:buyer_account))
    cinstance.application_id = 'custom_app_id'
    cinstance.save!
    assert_equal 'custom_app_id', cinstance.application_id

    invalid_cinstance = Cinstance.new(:plan => Factory(:application_plan, :issuer => provider.default_service),
                                      :user_account => cinstance.user_account)
    invalid_cinstance.application_id = 'custom_app_id'
    assert !invalid_cinstance.valid?
    assert invalid_cinstance.errors[:application_id].include?("has already been taken")
  end

  test 'updates service data when provider cinstance changes user_key' do
    provider_account = Factory(:provider_account)
    cinstance = provider_account.bought_cinstances.first

    ThreeScale::Core::Service.expects(:change_provider_key!).with(cinstance.user_key, anything)
    cinstance.change_user_key!
  end


  test 'stores backend application when cinstance is created' do
    provider_account = Factory(:provider_account)
    service = provider_account.default_service
    plan = Factory(:application_plan, :issuer => service)
    buyer_account = Factory(:buyer_account, :provider_account => provider_account)

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
    cinstance = Factory(:cinstance)

    ThreeScale::Core::Application.expects(:save)
        .with(has_entries(service_id: cinstance.service.backend_id,
                         id: cinstance.application_id,
                         state: 'suspended'))

    cinstance.suspend!
  end

  test 'updates backend application when cinstance changes end_user_required' do
    cinstance = Factory(:cinstance)

    ThreeScale::Core::Application.expects(:save)
      .with(has_entries(service_id: cinstance.service.backend_id,
                       id: cinstance.application_id,
                       user_required: true))

    cinstance.update_attribute :end_user_required, true
  end

  test 'updates backend application when cinstance changes plan' do
    cinstance = Factory(:cinstance)
    new_plan  = Factory(:application_plan, :service => cinstance.service)
    cinstance.plan = new_plan

    ThreeScale::Core::Application.expects(:save)
        .with(has_entries(service_id: cinstance.service.backend_id,
                         id: cinstance.application_id,
                         plan_id: new_plan.id,
                         plan_name: new_plan.name))

    cinstance.save!
  end

  test 'delete backend application when cinstance is destroyed' do
    cinstance = Factory(:cinstance)

    ThreeScale::Core::Application.expects(:delete)
      .with(cinstance.service.backend_id, cinstance.application_id)

    cinstance.destroy
  end

  test 'creates user_key to application_id mapping when provider cinstance is created' do
    service_id = user_key = app_id = nil

    ThreeScale::Core::Application.expects(:save_id_by_key)
        .at_least_once.with do |*params|
      service_id, user_key, app_id = params
    end

    provider_account = Factory(:provider_account)
    cinstance        = provider_account.bought_cinstance
    service          = Account.master.default_service

    assert_equal service.backend_id, service_id
    assert_equal cinstance.user_key, user_key
    assert_equal cinstance.application_id, app_id
  end

  test 'creates user_key to application_id mapping when buyer cinstance is created' do
    plan  = Factory(:application_plan)
    buyer = Factory(:buyer_account)

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
    plan         = Factory(:application_plan)
    buyer        = Factory(:buyer_account)
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
    plan         = Factory(:application_plan)
    buyer        = Factory(:buyer_account)
    cinstance    = Cinstance.create!(:plan => plan, :user_account => buyer)
    old_user_key = cinstance.user_key

    ThreeScale::Core::Application.expects(:save_id_by_key).never
    ThreeScale::Core::Application.expects(:delete_id_by_key)
      .with(plan.service.backend_id, old_user_key)

    cinstance.update_attribute(:user_key, '')
  end


  test 'deletes user_key to application_id mapping when cinstance is destroyed' do
    plan      = Factory(:application_plan)
    buyer     = Factory(:buyer_account)
    cinstance = Cinstance.create!(:plan => plan, :user_account => buyer)

    ThreeScale::Core::Application.expects(:delete_id_by_key)
      .with(plan.service.backend_id, cinstance.user_key)

    cinstance.destroy
  end

  test '#delete_backend_cinstance deletes application_keys, referrer_filters, user_key and application' do
    plan      = FactoryGirl.create(:application_plan)
    service   = plan.service
    buyer     = FactoryGirl.create(:buyer_account)
    cinstance = Cinstance.create!(plan: plan, user_account: buyer, service: service)
    FactoryGirl.create_list(:application_key, 2, application: cinstance)
    FactoryGirl.create_list(:referrer_filter, 2, application: cinstance)

    backend_id = service.backend_id
    app_id     = cinstance.application_id
    user_key   = cinstance.user_key

    cinstance.reload
    cinstance.application_keys.each { |app_key| ThreeScale::Core::ApplicationKey.expects(:delete).with(backend_id, app_id, app_key.value) }
    cinstance.referrer_filters.each { |referrer_filter| ThreeScale::Core::ApplicationReferrerFilter.expects(:delete).with(backend_id, app_id, referrer_filter.value) }
    ThreeScale::Core::Application.expects(:delete_id_by_key).with(backend_id, user_key)
    ThreeScale::Core::Application.expects(:delete).with(backend_id, app_id)

    cinstance.delete_backend_cinstance
  end
end
