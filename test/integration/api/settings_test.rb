require 'test_helper'

class Api::SettingsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)

    host! @provider.self_domain
  end

  def test_show
    params = { format: :json }

    get(admin_api_settings_path(params))
    assert_response 403

    params[:provider_key] = @provider.api_key

    get(admin_api_settings_path(params))
    assert_response :success

    expected_response = {
        settings: {
          useraccountarea_enabled: true,
          signups_enabled: true,
          account_approval_required: false,
          strong_passwords_enabled: false,
          public_search: false,
          account_plans_ui_visible: true,
          change_account_plan_permission: 'request',
          service_plans_ui_visible: true,
          change_service_plan_permission: 'request',
          end_user_plans_ui_visible: true
        }
    }.as_json

    assert_equal JSON.parse(@response.body), expected_response
  end

  def test_update
    params = { format: :json, provider_key: @provider.api_key,
               settings: { signups_enabled: false, change_account_plan_permission: 'chinchilla'}
    }

    assert 'request', @provider.settings.change_account_plan_permission
    assert @provider.settings.signups_enabled

    put(admin_api_settings_path(params))
    assert_response 422

    params[:settings][:change_account_plan_permission] = 'direct'
    put(admin_api_settings_path(params))
    assert_response :success

    @provider.reload
    assert 'direct', @provider.settings.change_account_plan_permission
    assert_not @provider.settings.signups_enabled
  end
end
