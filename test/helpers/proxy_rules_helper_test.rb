require 'test_helper'

class ProxyRulesHelperTest < ActionView::TestCase
  test 'generates the right path when it is a Proxy Rule with a Proxy' do
    proxy      = FactoryBot.build_stubbed(:proxy)
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: proxy)

    path = proxy_rule_path_for(proxy_rule)

    assert_equal(admin_service_proxy_rule_path(proxy_rule.owner.service, proxy_rule), path)
  end

  test 'generates the right path when it is a Proxy Rule with a Backend Api' do
    backend_api = FactoryBot.build_stubbed(:backend_api)
    proxy_rule  = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api)

    path = proxy_rule_path_for(proxy_rule)

    assert_equal(provider_admin_backend_api_mapping_rule_path(backend_api, proxy_rule), path)
  end

  test 'generates the right path when it is for edit' do
    backend_api = FactoryBot.build_stubbed(:backend_api)
    proxy_rule  = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api)

    path = proxy_rule_path_for(proxy_rule, edit: true)

    assert_equal(edit_provider_admin_backend_api_mapping_rule_path(backend_api, proxy_rule), path)
  end
end
