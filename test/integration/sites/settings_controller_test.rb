# frozen_string_literal: true

require 'test_helper'

class Sites::SettingsControllerTest < ActionDispatch::IntegrationTest

  test 'show emails tab if not master account' do
    provider = FactoryBot.create(:provider_account)

    login_provider provider

    get edit_admin_site_emails_path

    assert_response :success
  end

  test 'do not show emails tab if master account' do
    ThreeScale.config.stubs(onpremises: true, tenant_mode: 'master')

    member = FactoryBot.create(:simple_admin, account: master_account)
    member.activate!

    login! master_account, user: member

    get edit_admin_site_emails_path

    assert_response :forbidden
  end

  test 'update credit card policies paths successfully' do
    provider = FactoryBot.create(:provider_account)
    login_provider provider

    put admin_site_settings_path, params: {
      settings: {
        cc_terms_path: '/terms',
        cc_privacy_path: '/privacy',
        cc_refunds_path: '/refunds'
      }
    }

    assert_redirected_to edit_admin_site_settings_path
    assert_equal 'Settings updated', flash[:success]

    provider.settings.reload
    assert_equal '/terms', provider.settings.cc_terms_path
    assert_equal '/privacy', provider.settings.cc_privacy_path
    assert_equal '/refunds', provider.settings.cc_refunds_path
  end

  test 'update with empty values clears settings' do
    provider = FactoryBot.create(:provider_account)
    provider.settings.update(cc_terms_path: '/terms', cc_privacy_path: '/privacy')
    login_provider provider

    put admin_site_settings_path, params: {
      settings: {
        cc_terms_path: '',
        cc_privacy_path: ''
      }
    }

    assert_redirected_to edit_admin_site_settings_path

    provider.settings.reload
    assert_equal '', provider.settings.cc_terms_path
    assert_equal '', provider.settings.cc_privacy_path
  end
end
