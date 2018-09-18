require 'test_helper'

class Api::WebHooksTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)

    host! @provider.self_domain
  end

  def test_update
    params = { format: :json, provider_key: @provider.api_key, web_hook: { url: 'example', active: true }}
    refute @provider.web_hook.present?

    assert_no_difference(WebHook.method(:count)) do
      put(admin_api_webhooks_path(params))
      assert_response 422
    end

    assert_difference(WebHook.method(:count), +1) do
      params[:web_hook][:url] = 'http://example.com'
      put(admin_api_webhooks_path(params))
      assert_response 200
    end

    assert_no_difference(WebHook.method(:count)) do
      params[:web_hook][:url] = 'http://example.net'
      put(admin_api_webhooks_path(params))
      assert_response 200
    end
  end
end
