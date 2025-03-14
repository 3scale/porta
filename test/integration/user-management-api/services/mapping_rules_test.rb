# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Services::MappingRulesTest < ActionDispatch::IntegrationTest

  def setup
    @account = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:simple_service, account: @account)
    @proxy_rule = @service.proxy.proxy_rules.last

    host! @account.internal_admin_domain
  end

  def test_crud_access_token
    user = FactoryBot.create(:member, account: @account, member_permission_ids: [:partners], member_permission_service_ids: [])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    # index
    get(admin_api_service_proxy_mapping_rules_path(access_token_params))
    assert_response :forbidden
    get(admin_api_service_proxy_mapping_rules_path(access_token_params(token.value)))
    assert_response :not_found
    user.update(member_permission_service_ids: [@service.id])
    get(admin_api_service_proxy_mapping_rules_path(access_token_params(token.value)))
    assert_response :success

    # show
    params = access_token_params(token.value).merge(id: @proxy_rule.id)
    get(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success

    # create
    params = access_token_params(token.value).merge(mapping_rule_params)
    post(admin_api_service_proxy_mapping_rules_path(params))
    assert_response :success

    # update
    params = access_token_params(token.value).merge(id: @proxy_rule.id).merge(mapping_rule_params)
    put(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success

    # destroy
    params = access_token_params(token.value).merge(id: @proxy_rule.id)
    delete(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success
  end

  def test_crud_provider_key
    # index
    get(admin_api_service_proxy_mapping_rules_path(provider_key_params))
    assert_response :success

    # show
    params = provider_key_params.merge(id: @proxy_rule.id)
    get(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success

    # create
    params = provider_key_params.merge(mapping_rule_params)
    post(admin_api_service_proxy_mapping_rules_path(params))
    assert_response :success

    # update
    params = provider_key_params.merge(id: @proxy_rule.id).merge(mapping_rule_params)
    put(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success

    # destroy
    params = provider_key_params.merge(id: @proxy_rule.id)
    delete(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success
  end

  def test__with_position_and_last
    # create
    params = provider_key_params.merge(mapping_rule_params.deep_merge(mapping_rule: {position: 4, last: true}, format: :json))
    post(admin_api_service_proxy_mapping_rules_path(params))
    assert_response :success
    json = JSON.parse(response.body)

    rule = ProxyRule.find(json['mapping_rule']['id'])
    assert_equal 4, rule.position
    assert rule.last

    params = provider_key_params.merge(id: rule.id).merge(mapping_rule_params.deep_merge(mapping_rule: {position: 9, last: false}))
    put(admin_api_service_proxy_mapping_rule_path(params))
    assert_response :success
    rule.reload
    assert_equal 9, rule.position
    assert_not rule.last
  end

  private

  def mapping_rule_params
    {
      mapping_rule: {
        http_method: 'GET',
        delta:       '1',
        pattern:     '/alaska',
        metric_id:   @service.metrics.last.id
      }
    }
  end

  def access_token_params(token = '')
    default_params.merge({ access_token: token })
  end

  def provider_key_params
    default_params.merge({ provider_key: @account.provider_key })
  end

  def default_params
    { service_id: @service.id }
  end
end
