require 'test_helper'

class Apicast::ProxySourceTest < ActiveSupport::TestCase

  def test_proxy_rules
    proxy = FactoryBot.create(:proxy)
    rule_1 = FactoryBot.create(:proxy_rule, proxy: proxy, last: true)
    rule_2 = FactoryBot.create(:proxy_rule, proxy: proxy)

    source = Apicast::ProxySource.new(proxy).to_hash
    proxy_rules_source = source['proxy']['proxy_rules']
    assert proxy_rules_source
    assert find_by_id_in_hash(rule_1.id, proxy_rules_source)['last']
    refute find_by_id_in_hash(rule_2.id, proxy_rules_source)['last']
  end

  private

  def find_by_id_in_hash(id, hash)
    hash.find { |object| object['id'] == id }
  end
end
