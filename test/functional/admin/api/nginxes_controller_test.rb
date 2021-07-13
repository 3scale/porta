require 'test_helper'

class Admin::Api::NginxesControllerTest < ActionController::TestCase
  setup do
    Logic::RollingUpdates.stubs(skipped?: true)
  end

  test 'spec returns a json' do
    provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    host! provider.admin_domain

    get :spec, format: :json, provider_key: provider.api_key

    assert_response :success
    assert_equal provider.id, ActiveSupport::JSON.decode(@response.body)['id'].to_i
  end

end
