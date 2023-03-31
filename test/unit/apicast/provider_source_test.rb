require 'test_helper'

class Apicast::ProviderSourceTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build_stubbed(:simple_provider)
    @source = Apicast::ProviderSource.new(@account)
  end

  def test_attributes_for_proxy
    time = 10.days.ago.utc

    travel_to(time) do
      assert attributes = @source.attributes_for_proxy

      assert_equal time.iso8601, attributes[:timestamp]
    end
  end

  def test_id
    assert_equal @account.id, @source.id
  end

  def test_services
    proxy = FactoryBot.build_stubbed(:proxy)
    proxy.stubs(jwt_claim_with_client_id_type: 'plain', jwt_claim_with_client_id: 'azp')
    service = FactoryBot.build_stubbed(:simple_service, proxy: proxy)

    @account.stubs(services: [ service ])

    assert services = @source.services.presence, 'none services'
    assert_equal @account.services.size, services.size

    service.stubs(updated_at: Time.now)
    service_attributes =  @source.attributes_for_proxy['services'][0]
    assert_equal service.updated_at.to_i, service_attributes['updated_at'].to_time.to_i

    assert proxy_attributes = services.first.proxy

    assert_equal proxy.hosts, proxy_attributes.hosts
    assert_equal 'azp', service_attributes['proxy']['jwt_claim_with_client_id']
    assert_equal 'plain', service_attributes['proxy']['jwt_claim_with_client_id_type']
  end

  def test_policies_with_default_apicast_policy
    ThreeScale.config.stubs(onpremises: true)
    proxy = FactoryBot.build_stubbed(:proxy, policies_config: [{ name: 'cors',
                                                                  humanName: 'Cors Proxy',
                                                                  version: '0.0.1',
                                                                  description: 'Cors proxy for service 1',
                                                                  configuration: {foo: 'bar'},
                                                                  enabled: true,
                                                                  id: '1'
                                                                }])

    service = FactoryBot.build_stubbed(:simple_service, proxy: proxy)

    @account.stubs(services: [ service ])
    assert_equal [{'name' => 'cors', 'version' => '0.0.1', 'configuration' => {'foo' => 'bar'}},  {'name'=>'apicast', 'version'=>'builtin', 'configuration'=>{}}],
                 @source.attributes_for_proxy['services'][0]['proxy']['policy_chain']
    assert_nil @source.attributes_for_proxy['services'][0]['proxy']['policies_config']
  end
end
