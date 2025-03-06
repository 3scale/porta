require 'test_helper'

class ProxyRulesIndicesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'alphanumeric characters are indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.create(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/to/abc123')

        results = search_for('abc123', owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule.id], results
      end
    end
  end

  %w[- . _ ~].each do |char|
    test "character `#{char}` is indexed" do
      ThinkingSphinx::Test.rt_run do
        backend_api = FactoryBot.create(:backend_api)
        perform_enqueued_jobs(only: SphinxIndexationWorker) do
          proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: "/path/to/prefix#{char}suffix")

          results = search_for("prefix#{char}suffix", owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

          assert_equal [proxy_rule.id], results
        end
      end
    end
  end

  test 'search for exact match' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.create(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/abc123/to')
        FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/dont/match/at/all')
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/to/abc123')

        results = search_for('/path/to/abc123', owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal proxy_rule.id, results.first # The exact match should be returned first
        assert_equal 2, results.size # Return only patterns that match
      end
    end
  end

  test 'search for exact word' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.create(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/foo/to')
        FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/dont/match/at/all')
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/path/to/bar')

        results = search_for('bar', owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule.id], results
      end
    end
  end

  private

  def search_for(pattern, **options)
    search_options = ProxyRuleQuery::DEFAULT_SEARCH_OPTIONS.merge options
    ProxyRule.search(ThinkingSphinx::Query.escape(pattern), search_options).to_a
  end
end
