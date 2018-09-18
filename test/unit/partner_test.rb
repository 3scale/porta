require 'test_helper'

class PartnerTest < ActiveSupport::TestCase

  test 'should be valid' do
    partner = FactoryGirl.build(:partner)
    assert partner.valid?
    assert partner.save
  end

  test 'presence validations' do
    partner = Partner.new
    partner.save
    keys = partner.errors.messages.keys
    keys.include?(:name)
    keys.include?(:messages)
  end

  test 'has many providers' do
    partner = FactoryGirl.create(:partner)
    provider = FactoryGirl.create(:simple_provider)
    partner.providers << provider
    assert_equal [provider], partner.providers
  end

  test 'has many applicatio_plans' do
    partner = FactoryGirl.create(:partner)
    application_plan = FactoryGirl.create(:application_plan)
    partner.application_plans << application_plan
    assert_equal [application_plan], partner.application_plans
  end

  test 'has signup_type' do
    partner = FactoryGirl.build_stubbed(:partner, system_name: 'some-name')

    assert_equal 'partner:some-name', partner.signup_type
  end

  test 'can manage users?' do
    partner = FactoryGirl.build_stubbed(:partner)

    partner.system_name = 'heroku'
    assert_equal false, partner.can_manage_users?

    partner.system_name = 'appdirect'
    assert_equal false, partner.can_manage_users?

    partner.system_name = 'redhat'
    assert_equal true, partner.can_manage_users?
  end
end
