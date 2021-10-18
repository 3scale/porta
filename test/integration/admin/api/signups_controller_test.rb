# frozen_string_literal: true

require 'test_helper'

class Admin::Api::SignupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.admin_domain
  end

  attr_reader :provider

  class WebHooksTest < Admin::Api::SignupsControllerTest
    disable_transactional_fixtures!

    test 'create by access token fires webhooks' do
      provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: provider, account_created_on: true, active: true)

      assert_difference(provider.buyers.method(:count)) do
        assert_difference(WebHookWorker.jobs.method(:size)) do
          post(admin_api_signup_path, params: { format: :json, access_token: token.value, org_name: 'company', username: 'person' })
          assert_response :created
        end
      end
    end

    test 'create by provider key does not fire webhooks' do
      provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: provider, account_created_on: true, active: true)

      assert_difference(provider.buyers.method(:count)) do
        assert_no_difference(WebHookWorker.jobs.method(:size)) do
          post(admin_api_signup_path, params: { format: :json, provider_key: provider.provider_key, org_name: 'company', username: 'person' })
          assert_response :created
        end
      end
    end
  end

  private

  def token(user: provider.admin_user)
    @token ||= FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'rw')
  end
end
