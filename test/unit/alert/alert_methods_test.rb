require_relative '../../test_helper'

class AlertMethodsTest < ActiveSupport::TestCase
  def setup
    provider    = FactoryBot.create(:provider_account)
    service    = provider.first_service!
    buyer       = FactoryBot.create(:buyer_account, :provider_account => provider)
    plan              = FactoryBot.create(:application_plan, :issuer => service)
    cinstance         = FactoryBot.create(:cinstance, :plan => plan, :user_account => buyer)
    @alert = FactoryBot.build(:limit_alert, :id => 4, :account_id => buyer.id, :cinstance => cinstance, :timestamp => "2011-07-07 23:25:53 +0000",
                       :utilization=> 50, :level => 100, :message => "hits per month: 115 of 100", :tenant_id => provider.id)

  end

  should 'display metric friendly name' do
    assert_equal @alert.friendly_name, "Hits"
  end

  should 'display friendly message' do
    assert_equal @alert.friendly_message, "Hits per month: 115 of 100"
  end

  should 'find metric of backend' do
    service = @alert.cinstance.service
    backend_api = FactoryBot.create(:backend_api, name: 'Other API', system_name: 'other_api', account: service.provider)
    backend_metric = FactoryBot.create(:metric, owner: backend_api, system_name: 'backend_metric')
    service.backend_api_configs.create!(backend_api: backend_api, path: '/other-api')

    @alert.message = "#{backend_metric['system_name']} per day: 115 of 100"
    assert_equal backend_metric, @alert.metric
  end
end
