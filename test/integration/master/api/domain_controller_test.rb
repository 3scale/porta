# frozen_string_literal: true

require 'test_helper'

class Master::Api::DomainControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! master_account.domain
    @token =  FactoryGirl.create(:access_token,
                                 owner: master_account.first_admin!,
                                 scopes: 'account_management')
  end

  test 'show' do
    domain = master_account.domain
    get master_api_domain_path(domain, access_token: @token.value)

    assert_response :success

    assert_equal System::DomainInfo.find(domain).as_json,
                 JSON.parse(response.body)
  end

  test 'unauthorized' do
    get master_api_domain_path(master_account.domain, access_token: 'invalid')

    assert_response :unauthorized
  end
end
