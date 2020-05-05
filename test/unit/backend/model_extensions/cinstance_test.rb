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

  test '#delete_backend_cinstance deletes application_keys, referrer_filters, user_key and application' do
    plan      = FactoryBot.create(:application_plan)
    service   = plan.service
    buyer     = FactoryBot.create(:buyer_account)
    cinstance = Cinstance.create!(plan: plan, user_account: buyer, service: service)
    FactoryBot.create_list(:application_key, 2, application: cinstance)
    FactoryBot.create_list(:referrer_filter, 2, application: cinstance)

    backend_id = service.backend_id
    app_id     = cinstance.application_id
    user_key   = cinstance.user_key

    cinstance.reload
    cinstance.application_keys.each { |app_key| ThreeScale::Core::ApplicationKey.expects(:delete).with(backend_id, app_id, app_key.value) }
    cinstance.referrer_filters.each { |referrer_filter| ThreeScale::Core::ApplicationReferrerFilter.expects(:delete).with(backend_id, app_id, referrer_filter.value) }
    ThreeScale::Core::Application.expects(:delete).with(backend_id, app_id)

    cinstance.delete_backend_cinstance
  end
end
