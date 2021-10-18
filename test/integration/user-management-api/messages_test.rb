# frozen_string_literal: true

# encoding: utf-8
require 'test_helper'

class Admin::Api::MessagesTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @buyer    = FactoryBot.create :buyer_account,    :provider_account => @provider

    host! @provider.admin_domain
  end

  test 'create' do
    post(admin_api_account_messages_path(@buyer, format: :json), params: { message: { body: "Lluís Companys is calling" }, provider_key: @provider.api_key })

    assert_response :success
    assert_equal 'sent', JSON.parse(@response.body)['message']['state']
  end

  test "create with string 'message' returns 422" do
    post(admin_api_account_messages_path(@buyer, format: :xml), params: { message: "text-inline", provider_key: @provider.api_key })

    assert_response 422
  end

  test 'create flattened' do
    post(admin_api_account_messages_path(@buyer, format: :xml), body: "text of the message", provider_key: @provider.api_key)

    assert_response :success
  end

  # this test is not a good idea. but anyway...
  test 'security: access denied in buyer side' do
    host! @provider.domain
    get admin_api_account_applications_path(@buyer, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :forbidden
  end
end
