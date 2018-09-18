require_relative '../../test_helper'

class AlertMethodsTest < ActiveSupport::TestCase
  def setup
    provider    = Factory(:provider_account)
    service    = provider.first_service!
    service_id = service.backend_id
    buyer       = Factory(:buyer_account, :provider_account => provider)
    plan              = Factory(:application_plan, :issuer => service)
    cinstance         = Factory(:cinstance, :plan => plan, :user_account => buyer)
    @alert = Factory.build(:limit_alert, :id => 4, :account_id => buyer.id, :cinstance => cinstance, :timestamp => "2011-07-07 23:25:53 +0000",
                       :utilization=> 50, :level => 100, :message => "hits per month: 115 of 100", :tenant_id => provider.id)

  end

  should 'display metric friendly name' do
    assert_equal @alert.friendly_name, "Hits"
  end

  should 'display friendly message' do
    assert_equal @alert.friendly_message, "Hits per month: 115 of 100"
  end

end
