# frozen_string_literal: true

require 'test_helper'

module DataMigrations
  class UpdateProxyRuleOwnersTest < DataMigrationTest
    test 'updates metrics owned by services' do
      proxy_rules = FactoryBot.create_list(:proxy_rule, 3)
      ProxyRule.where(id: proxy_rules.map(&:id)).update_all(owner_id: nil, owner_type: nil)
      FactoryBot.create(:proxy_rule, proxy_id: nil, owner: FactoryBot.create(:backend_api))
      assert_change of: ->{ ProxyRule.where(owner_type: 'Proxy').count }, by: 3 do
        UpdateProxyRuleOwners.new.up
      end
    end
  end
end
