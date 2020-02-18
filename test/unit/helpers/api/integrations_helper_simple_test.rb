require 'test_helper'

class Api::IntegrationsHelperSimpleTest < ActionView::TestCase
  include Api::IntegrationsHelper

  test 'print the proper preview' do
    pattern = '/foo'
    backend_api = FactoryBot.create(:backend_api)
    FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil, pattern: pattern)
    backend_api_config = FactoryBot.create(:backend_api_config)
    backend_api_config.stubs(:path).returns('/')

    assert_equal pattern, proxy_rule_uri(backend_api_config.path, backend_api.proxy_rules.last)
  end
end
