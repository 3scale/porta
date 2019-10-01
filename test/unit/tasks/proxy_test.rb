# frozen_string_literal: true

require 'test_helper'

class Tasks::ProxyTest < ActiveSupport::TestCase
  test 'update_proxy_rule_owners' do
    proxy_rules = FactoryBot.create_list(:proxy_rule, 3)
    ProxyRule.where(id: proxy_rules.map(&:id)).update_all(owner_id: nil, owner_type: nil)
    FactoryBot.create(:proxy_rule, proxy_id: nil, owner: FactoryBot.create(:backend_api))
    assert_change of: ->{ ProxyRule.where(owner_type: 'Proxy').count }, by: 3 do
      execute_rake_task 'proxy.rake', 'proxy:update_proxy_rule_owners'
    end
  end
end
