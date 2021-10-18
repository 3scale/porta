# frozen_string_literal: true

require 'test_helper'

class Admin::Api::SsoTokensTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account, :domain => 'provider.example.com')

    host! @provider.admin_domain
  end

  test 'api should access deny on missing provider_key param' do
    post(admin_api_sso_tokens_path, :format => :xml)

    assert_response :forbidden
  end

  test 'creating a valid sso token' do
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)

    post(admin_api_sso_tokens_path, params: { :format => :xml, :provider_key => @provider.api_key, :user_id => buyer.users.first.id, :expires_in => 6000 })

    assert_response :created
  end

  test 'creating an sso token for ssl' do
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)

    post(admin_api_sso_tokens_path, params: { :format => :xml, :protocol => 'https', :provider_key => @provider.api_key, :user_id => buyer.users.first.id, :expires_in => 6000 })

    assert_response :created
  end

  # attempt to create an sso token for someone's else user
  #  - using un-flatten parameters to check how wrap_parameters works.
  #  - is also passing an username to the api
  #  - is also not passing an expires_in
  test 'creating an sso token for another provider buyer' do
    buyer = FactoryBot.create(:buyer_account, :provider_account => FactoryBot.create(:simple_provider))

    post(admin_api_sso_tokens_path, params: { :format => :xml, :provider_key => @provider.api_key, :sso_token => { :username => buyer.users.first.username } })

    assert_response 422

    xml = Nokogiri::XML::Document.parse response.body

    error_message = xml.xpath("//errors/error").text

    assert_match /Username is invalid/, error_message
  end
end
