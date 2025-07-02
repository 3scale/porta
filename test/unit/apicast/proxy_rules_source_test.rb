require 'test_helper'

class Apicast::ProxyRulesSourceTest < ActiveSupport::TestCase

  def setup
    @proxy = FactoryBot.create(:proxy)
    backend_api_config = FactoryBot.create(:backend_api_config, service: @proxy.service, path: '/test/path/')
    @backend_api = backend_api_config.backend_api
    @metric = FactoryBot.create(:metric, owner: backend_api, description: 'My awesome metric', system_name: 'my-metric')
  end

  attr_reader :backend_api, :metric, :proxy

  def test_to_hash
    rule_1 = FactoryBot.create(:proxy_rule, proxy: proxy, last: true)
    rule_2 = FactoryBot.create(:proxy_rule, proxy: proxy)

    rule_3 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/create')
    rule_4 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/delete', metric: metric)
    rule_5 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/list?filter=a', metric: metric)
    rule_6 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/users/{username}', metric: metric)

    source = Apicast::ProxyRulesSource.new(proxy).to_hash

    assert find_by_id_in_hash(rule_1.id, source)
    assert find_by_id_in_hash(rule_2.id, source)

    rule_hash_3 = find_by_id_in_hash(rule_3.id, source)
    rule_hash_4 = find_by_id_in_hash(rule_4.id, source)
    rule_hash_5 = find_by_id_in_hash(rule_5.id, source)
    rule_hash_6 = find_by_id_in_hash(rule_6.id, source)

    assert rule_hash_3 && rule_hash_4
    assert_equal '/test/path/create', rule_hash_3['pattern']
    assert_equal '/test/path/delete', rule_hash_4['pattern']
    assert_equal metric['system_name'], rule_hash_4['metric_system_name']
    assert_equal({'filter' => 'a'}, rule_hash_5['querystring_parameters'])
    assert_equal ['username'], rule_hash_6['parameters']
  end

  test 'backend api mapping rules are ordered by position' do
    proxy.proxy_rules.destroy_all

    assert backend_api.proxy_rules.empty?

    FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/two')
    rule_3 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/three')
    rule_1 = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/one')
    rule_1.move_to_top
    rule_3.move_to_bottom

    source = Apicast::ProxyRulesSource.new(proxy).to_hash
    assert_equal %w[/test/path/one /test/path/two /test/path/three], source.map { |rule| rule['pattern'] }
  end

  private

  def find_by_id_in_hash(id, hash)
    hash.find { |object| object['id'] == id }
  end
end
