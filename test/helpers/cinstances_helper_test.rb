require 'test_helper'

class CinstancesHelperTest < ActionView::TestCase

  test 'application_friendly_name method' do
    account   = FactoryBot.build_stubbed(:simple_buyer, name: 'Alex')
    plan      = FactoryBot.build_stubbed(:simple_application_plan, name: 'planLALA')
    cinstance = FactoryBot.build_stubbed(:simple_cinstance, user_account: account, plan: plan)

    cinstance.name = 'OLA'
    assert_equal 'OLA application', application_friendly_name(cinstance)

    cinstance.name = 'HOLA application'
    assert_equal 'HOLA application', application_friendly_name(cinstance)

  end
end
