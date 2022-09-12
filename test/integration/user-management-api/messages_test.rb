# frozen_string_literal: true

require 'test_helper'

class Admin::Api::MessagesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)

    host! @provider.external_admin_domain
  end

  test 'create' do
    post admin_api_account_messages_path(@buyer, format: :json), params: { message: { body: "Lluís Companys is calling" , 
      subject: "I am subject" }, provider_key: @provider.api_key }

    assert_response :success
    assert_equal 'sent', JSON.parse(@response.body)['message']['state']
  end

  test "create with string 'message' returns 422" do
    post admin_api_account_messages_path(@buyer, format: :xml), params: { message: "text-inline", provider_key: @provider.api_key }

    assert_response 422
  end

  test 'create flattened' do
    post admin_api_account_messages_path(@buyer, format: :xml), params: { body: "text of the message", subject: "I am subject",
     provider_key: @provider.api_key }

    assert_response :success
  end

  # this test is not a good idea. but anyway...
  test 'security: access denied in buyer side' do
    host! @provider.internal_domain
    get admin_api_account_applications_path(@buyer, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :forbidden
  end
end
