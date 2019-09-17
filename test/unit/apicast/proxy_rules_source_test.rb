require 'test_helper'

class Apicast::ProxyRulesSourceTest < ActiveSupport::TestCase

  def test_to_hash
    proxy = FactoryBot.create(:proxy)
    rule_1 = FactoryBot.create(:proxy_rule, proxy: proxy, last: true)
    rule_2 = FactoryBot.create(:proxy_rule, proxy: proxy)

    backend_api_config = FactoryBot.create(:backend_api_config, service: proxy.service, path: '/test/path/')
    backend_api = backend_api_config.backend_api
    metric = FactoryBot.create(:metric, owner: backend_api, description: 'My awesome metric', system_name: 'my-metric')
    rule_3 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/create')
    rule_4 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/delete', metric: metric)

    source = Apicast::ProxyRulesSource.new(proxy).to_hash

    assert find_by_id_in_hash(rule_1.id, source)
    assert find_by_id_in_hash(rule_2.id, source)

    rule_hash_3 = find_by_id_in_hash(rule_3.id, source)
    rule_hash_4 = find_by_id_in_hash(rule_4.id, source)

    assert rule_hash_3 && rule_hash_4
    assert_equal '/test/path/create', rule_hash_3['pattern']
    assert_equal '/test/path/delete', rule_hash_4['pattern']
    assert_equal metric['system_name'], rule_hash_4['metric_system_name']
  end

  private

  def find_by_id_in_hash(id, hash)
    hash.find { |object| object['id'] == id }
  end
end
