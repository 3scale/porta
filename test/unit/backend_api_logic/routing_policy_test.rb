# frozen_string_literal: true

require 'test_helper'

module BackendApiLogic
  class RoutingPolicyTest < ActiveSupport::TestCase
    setup do
      @service = FactoryBot.create(:simple_service)
      first_backend_api = FactoryBot.create(:backend_api_config, path: '', service: @service).backend_api
      other_backend_api = FactoryBot.create(:backend_api, system_name: 'foo')
      @backend_apis = [first_backend_api, other_backend_api]
      @service.backend_api_configs.create(backend_api: other_backend_api, path: 'foo')
    end

    attr_reader :service, :backend_apis
    delegate :proxy, to: :service

    test '#with_subpaths?' do
      assert proxy.with_subpaths?
      other_proxy = FactoryBot.create(:proxy)
      refute other_proxy.with_subpaths?
    end

    test '#policy_chain' do
      backend_api1 = backend_apis.first
      backend_api2 = backend_apis.last
      injected_rules = [
        { url: backend_api2.private_endpoint, owner_id: backend_api2.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '/foo/.*|/foo/?'] }, replace_path: "{{original_request.path | remove_first: '/foo'}}" },
        { url: backend_api1.private_endpoint, owner_id: backend_api1.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '/.*'] } }
      ]
      apicast_policy = { name: 'apicast', 'version': 'builtin', 'configuration': {} }
      injected_policy = {
        name: "routing",
        version: "builtin",
        enabled: true,
        configuration: { rules: injected_rules }
      }
      assert_equal [injected_policy, apicast_policy].as_json, proxy.policy_chain
    end

    class RuleTest < ActiveSupport::TestCase
      setup do
        @rule_class = RoutingPolicy.const_get(:Builder).const_get(:Rule)
      end

      attr_reader :rule_class

      test '#replace_path' do
        [
          [{ private_endpoint: 'http://actual-api.behind.com/ns/', path: '/' }, nil],
          [{ private_endpoint: 'https://safe-second-api.io', path: '/' }, nil],
          [{ private_endpoint: 'https://safe-second-api.io/v2', path: '/' }, nil],
          [{ private_endpoint: 'http://actual-api.behind.com/ns/', path: '/hey' }, "{{original_request.path | remove_first: '/hey'}}"],
          [{ private_endpoint: 'https://safe-second-api.io', path: '/ho' }, "{{original_request.path | remove_first: '/ho'}}"],
          [{ private_endpoint: 'https://safe-second-api.io/v2', path: '/lets-go' }, "{{original_request.path | remove_first: '/lets-go'}}"]
        ].each do |config, replace_path_value|
          expected_replace_path = replace_path_value ? { replace_path: replace_path_value } : {}
          assert_equal expected_replace_path, rule_class.new(stub(config)).replace_path
        end
      end

      test 'replace_path config only included when the config has a path' do
        refute rule_class.new(stub(backend_api_id: 1, private_endpoint: 'http://whatever', path: '/')).as_json.has_key?(:replace_path)
        assert rule_class.new(stub(backend_api_id: 2, private_endpoint: 'http://whatever', path: 'foo')).as_json.has_key?(:replace_path)
      end
    end
  end
end
