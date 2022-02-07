# frozen_string_literal: true

require 'test_helper'

class ProxyRuleTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#search_for uses sphinx if query given' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/test')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('test')
      end
    end
  end

  test '#search_for reuses the scope if given' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule   = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/test1', position: 1)
        proxy_rule2  = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/test2', position: 2)
        query        = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)
        scope        = ProxyRule.where(position: 2)

        assert_equal [proxy_rule2], query.search_for('test', scope)
      end
    end
  end

  test '#search_for order result if sort/direction parameters given' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule   = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/test1', position: 1)
        proxy_rule2  = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/test2', position: 2)
        query        = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id,
                                          sort: :position, direction: :desc)

        assert_equal [proxy_rule2, proxy_rule], query.search_for('test')
      end
    end
  end

  test '#search_for does not use sphinx if no query given' do
    ThinkingSphinx::Test.rt_run do
      ThinkingSphinx::Search.expects(:new).never
      query = ProxyRuleQuery.new(owner_type: 'BackendApi', owner_id: master_account.id)

      assert_equal master_account.proxy_rules, query.search_for('')
    end
  end
end
