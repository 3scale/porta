require 'test_helper'

class Apicast::ProxySourceTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.create(:proxy)
    @source = Apicast::ProxySource.new(@proxy)
  end

  attr_reader :proxy, :source

  test 'proxy rules' do
    rule_1 = FactoryBot.create(:proxy_rule, proxy: proxy, last: true)
    rule_2 = FactoryBot.create(:proxy_rule, proxy: proxy)

    proxy_rules_source = source.to_hash.dig('proxy', 'proxy_rules')
    assert proxy_rules_source
    assert find_by_id_in_hash(rule_1.id, proxy_rules_source)['last']
    refute find_by_id_in_hash(rule_2.id, proxy_rules_source)['last']
  end

  test 'does not include ignored columns of Service' do
    source_hash = source.to_hash.with_indifferent_access
    Service.ignored_columns.each { |column| source_hash[column] }
  end

  private

  def find_by_id_in_hash(id, hash)
    hash.find { |object| object['id'] == id }
  end
end
