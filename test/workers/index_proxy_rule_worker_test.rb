require 'test_helper'

class IndexProxyRuleWorkerTest < ActiveSupport::TestCase
  test 'it does not raises RecordNotFound if id does not exist' do
    # shouldn't raise anything
    IndexProxyRuleWorker.perform_now(42)
  end

  test 'indexes the proxy rule in Sphinx if record exists' do
    proxy_rule = FactoryBot.create(:proxy_rule)
    ThinkingSphinx::RealTime::Callbacks::RealTimeCallbacks.any_instance
      .expects(:after_commit)

    IndexProxyRuleWorker.perform_now(proxy_rule.id)
  end
end
