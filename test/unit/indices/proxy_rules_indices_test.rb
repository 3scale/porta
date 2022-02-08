require 'test_helper'

class ProxyRulesIndicesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'alphanumeric characters are indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/abc/123')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/abc/123')
      end
    end
  end

  test 'character `/` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/')
      end
    end
  end

  test 'character `!` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/!/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/!/')
      end
    end
  end

  test "character `'` is indexed" do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: "/'/")
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for("/'/")
      end
    end
  end

  test 'characters `()` are indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/()/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/()/')
      end
    end
  end

  test 'character `*` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/*/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/*/')
      end
    end
  end

  test 'character `+` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/+/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/+/')
      end
    end
  end

  test 'character `,` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/,/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/,/')
      end
    end
  end

  test 'character `-` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/-/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/-/')
      end
    end
  end

  test 'character `.` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/./')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/./')
      end
    end
  end

  test 'character `_` is indexed' do
    ThinkingSphinx::Test.rt_run do
      backend_api = FactoryBot.build_stubbed(:backend_api)
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, pattern: '/_/')
        query      = ProxyRuleQuery.new(owner_type: proxy_rule.owner_type, owner_id: proxy_rule.owner_id)

        assert_equal [proxy_rule], query.search_for('/_/')
      end
    end
  end

end
