require 'test_helper'

class Liquid::Drops::ServiceDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @service = Factory(:service)
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
end
