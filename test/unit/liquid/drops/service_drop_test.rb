require 'test_helper'

class Liquid::Drops::ServiceDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @service = FactoryBot.create(:service)
    @drop = Drops::Service.new(@service)
  end

  test 'support emails' do
    assert_equal @drop.support_email, @service.support_email
  end

  test 'subscription' do
    buyer = Factory(:buyer_account, provider_account: @service.provider)
    User.current = buyer.admins.first

    # service subscription is missing
    assert_nil @drop.subscription

    # service subscription exists
    plan =  @service.service_plans.create! name: 'awesome', system_name: 'cool'
    ServiceContract.create! plan: plan, user_account: buyer
    assert_not_nil @drop.subscription
  end

  test 'api_specs' do
    api_spec = FactoryBot.create(:api_docs_service, service: @service, account: @service.account)
    api_specs_collection_drop = @drop.api_specs
    assert_equal 1, api_specs_collection_drop.length
    api_spec_drop = api_specs_collection_drop.first
    assert_instance_of Liquid::Drops::ApiSpec, api_spec_drop
    assert_equal api_spec.system_name, api_spec_drop.system_name
  end
end
