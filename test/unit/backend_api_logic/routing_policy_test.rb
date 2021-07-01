# frozen_string_literal: true

require 'test_helper'

module BackendApiLogic
  class RoutingPolicyTest < ActiveSupport::TestCase
    setup do
      @service = FactoryBot.create(:simple_service)
      @first_backend_api = FactoryBot.create(:backend_api_config, path: '', service: @service).backend_api
      @other_backend_api = FactoryBot.create(:backend_api, system_name: 'foo')
      @service.backend_api_configs.create(backend_api: other_backend_api, path: 'foo')
    end

    attr_reader :service, :first_backend_api, :other_backend_api
    delegate :proxy, to: :service

    test '#with_subpaths?' do
      assert proxy.with_subpaths?
      other_proxy = FactoryBot.create(:proxy)
      refute other_proxy.with_subpaths?
    end

    test '#policy_chain' do
      injected_policy = {
        name: 'routing',
        version: 'builtin',
        enabled: true,
        configuration: {
          rules: [
            { url: other_backend_api.private_endpoint, owner_id: other_backend_api.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '^(/foo/.*|/foo/?)'] }, replace_path: "{{uri | remove_first: '/foo'}}" },
            { url: first_backend_api.private_endpoint, owner_id: first_backend_api.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '^(/.*)'] } }
          ]
        }
      }

      assert_equal [injected_policy, apicast_policy.except(:enabled)].as_json, proxy.policy_chain
    end

    test 'other routing policies are merged' do
      routing_rule = { url: 'https://echo-api.3scale.net:443', condition: { operations: [{ match: 'header', op: '==', value: 'echo', header_name: 'Redirect' }] } }
      routing_policy = {
        name: 'routing',
        version: 'builtin',
        enabled: true,
        configuration: { rules: [routing_rule] }
      }
      proxy.stubs(:policies_config).returns(Proxy::PoliciesConfig.new([routing_policy, apicast_policy]))

      injected_policy = {
        name: 'routing',
        version: 'builtin',
        enabled: true,
        configuration: {
          rules: [
            { url: other_backend_api.private_endpoint, owner_id: other_backend_api.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '^(/foo/.*|/foo/?)'] }, replace_path: "{{uri | remove_first: '/foo'}}" },
            { url: first_backend_api.private_endpoint, owner_id: first_backend_api.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '^(/.*)'] } },
            routing_rule
          ]
        }
      }

      assert_equal [injected_policy, apicast_policy.except(:enabled)].as_json, proxy.policy_chain
    end

    test 'routing policy before apicast policy' do
      injected_policy = {
        name: 'routing',
        version: 'builtin',
        enabled: true,
        configuration: {
          rules: [
            { url: other_backend_api.private_endpoint, owner_id: other_backend_api.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '^(/foo/.*|/foo/?)'] }, replace_path: "{{uri | remove_first: '/foo'}}" },
            { url: first_backend_api.private_endpoint, owner_id: first_backend_api.id, owner_type: 'BackendApi', condition: { operations: [match: :path, op: :matches, value: '^(/.*)'] } },
          ]
        }
      }
      policy_blah = { name: 'blah', version: 'builtin', enabled: true, configuration: {} }
      policy_bleh = { name: 'bleh', version: 'builtin', enabled: true, configuration: {} }

      proxy.stubs(:policies_config).returns(Proxy::PoliciesConfig.new([apicast_policy, policy_blah, policy_bleh]))
      assert_equal [injected_policy, apicast_policy.except(:enabled), policy_blah.except(:enabled), policy_bleh.except(:enabled)].as_json, proxy.policy_chain

      proxy.stubs(:policies_config).returns(Proxy::PoliciesConfig.new([policy_blah, apicast_policy, policy_bleh]))
      assert_equal [policy_blah.except(:enabled), injected_policy, apicast_policy.except(:enabled), policy_bleh.except(:enabled)].as_json, proxy.policy_chain

      proxy.stubs(:policies_config).returns(Proxy::PoliciesConfig.new([policy_blah, policy_bleh, apicast_policy]))
      assert_equal [policy_blah.except(:enabled), policy_bleh.except(:enabled), injected_policy, apicast_policy.except(:enabled)].as_json, proxy.policy_chain
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
          [{ private_endpoint: 'http://actual-api.behind.com/ns/', path: '/hey' }, "{{uri | remove_first: '/hey'}}"],
          [{ private_endpoint: 'https://safe-second-api.io', path: '/ho' }, "{{uri | remove_first: '/ho'}}"],
          [{ private_endpoint: 'https://safe-second-api.io/v2', path: '/lets-go' }, "{{uri | remove_first: '/lets-go'}}"]
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

    protected

    def apicast_policy
      { name: 'apicast', version: 'builtin', enabled: true, configuration: {} }
    end
  end
end
