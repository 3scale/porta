require 'test_helper'

class ProxyRulesIndicesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'alphanumeric characters are indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.create(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/to/abc123')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('abc123')
      end
    end
  end

  %w[- . _ ~].each do |char|
    test "character `#{char}` is indexed" do
      ThinkingSphinx::Test.rt_run do
        backend_api = FactoryBot.create(:backend_api)
        perform_enqueued_jobs(only: SphinxIndexationWorker) do
          proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: "/path/to/prefix#{char}suffix")
          query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

          assert_equal [proxy_rule], query.search_for("prefix#{char}suffix")
        end
      end
    end
  end
end
