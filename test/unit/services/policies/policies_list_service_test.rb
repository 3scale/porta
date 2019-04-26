# frozen_string_literal: true

require 'test_helper'

class Policies::PoliciesListServiceTest < ActiveSupport::TestCase

  APICAST_REGISTRY_URL = 'https://apicast-staging.proda.example.com/policies'

  def setup
    @service = Policies::PoliciesListService
    ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: APICAST_REGISTRY_URL)
  end

  def stub_apicast_request(status: 200, body: GATEWAY_API_MANAGEMENT_RESPONSE.to_json)
    stub_request(:get, APICAST_REGISTRY_URL).to_return(status: status, body: body, headers: { 'Content-Type' => 'application/json' })
  end

  GATEWAY_API_MANAGEMENT_RESPONSE = {
    policies: {
      cors: [{
        version: 'builtin',
        description: 'CORS Policy'
      }],
      tls: [{
        version: 'builtin',
        description: 'TLS Policy'
      }]
    }
  }.freeze

  test 'call with error response on gateway side' do
    stub_apicast_request(status: 502, body: '{"error":"A server error occured"}')
    assert_nil @service.call(Account.new)
  end

  test 'call with no apicast registry url' do
    ThreeScale.config.sandbox_proxy.expects(:apicast_registry_url).returns(nil)
    JSONClient.expects(:get).with(nil).raises(SocketError)

    assert_nil @service.call(Account.new)
  end
  
  test 'call with no ok response' do
    stub_apicast_request(status: 500)
    assert_nil @service.call(Account.new)
  end

  test 'call with no access to registry' do
    stub_apicast_request

    account = FactoryBot.build_stubbed(:simple_provider)
    account.expects(:provider_can_use?).with(:policy_registry).returns(false)
    account.expects(:policies).never

    policies = @service.call(account)
    assert_equal GATEWAY_API_MANAGEMENT_RESPONSE[:policies].as_json, policies
  end

  test 'call with custom policies' do
    stub_apicast_request

    account = FactoryBot.build_stubbed(:simple_provider)

    cors_v2 = {
      version: '2.0.0',
      description: 'CORS Policy V2'
    }

    header_v1 = {
      version: '1.1.5',
      description: 'Header Policy V1'
    }

    policies = [
      Policy.new(name: 'cors', version: '2.0.0', schema: cors_v2),
      Policy.new(name: 'header', version: '1.1.5', schema: header_v1),
    ]

    account.expects(:provider_can_use?).with(:policy_registry).returns(true)
    account.expects(:policies).returns(policies)

    custom_policies = GATEWAY_API_MANAGEMENT_RESPONSE.dup
    custom_policies[:policies][:cors].push(cors_v2)
    custom_policies[:policies][:header] = [header_v1]

    assert_equal custom_policies[:policies].as_json, @service.call(account)
  end

  class PolicyListTest < ActiveSupport::TestCase

    def test_add
      policy1_schema_v1 =  {
        version: '1.0.0',
        description: 'Some description'
      }.as_json

      policy1_schema_v2 =  {
        version: '2.0.0',
        description: 'Some description'
      }.as_json

      hash = {
        policy1: [
          policy1_schema_v1
        ]
      }.as_json


      list = Policies::PoliciesListService::PolicyList.from_hash(hash)
      assert_equal hash, list.to_h

      list.add(Policy.new(name: 'policy1', version: '1.0.0', schema: policy1_schema_v1))
      list.add(Policy.new(name: 'policy1', version: '2.0.0', schema: policy1_schema_v2))

      new_hash = hash.dup
      new_hash['policy1'].push(policy1_schema_v2)
      assert_equal new_hash, list.to_h
    end

    def test_merge
      list1 = Policies::PoliciesListService::PolicyList.from_hash({pol: [{version: '1.0'}]})
      list2 = Policies::PoliciesListService::PolicyList.from_hash({pol: [{version: '2.0'}], pol2: [{version: '3.0'}]})
      list3 = list1.merge(list2)
      expected_hash = {
        pol: [
          {version: '1.0'},
          {version: '2.0'}
        ],
        pol2: [
          {version: '3.0'}
        ]
      }.as_json
      assert_equal(expected_hash, list3.to_h)
    end
  end
end
