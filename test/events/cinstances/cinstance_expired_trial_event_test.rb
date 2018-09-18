require 'test_helper'

class Cinstances::CinstanceExpiredTrialEventTest < ActiveSupport::TestCase

  def test_create
    cinstance = FactoryGirl.build_stubbed(:simple_cinstance, id: 1)
    cinstance.stubs(:provider_account_id).returns(10)
    event     = Cinstances::CinstanceExpiredTrialEvent.create(cinstance)

    assert event
    assert_equal event.cinstance, cinstance
    assert_equal event.provider, cinstance.provider_account
    assert_equal event.service, cinstance.issuer
  end
end
