# frozen_string_literal: true

require 'test_helper'

class Sites::SettingsControllerTest < ActionDispatch::IntegrationTest

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

  test 'update with invalid values shows errors' do
    provider = FactoryBot.create(:provider_account)
    login_provider provider

    long_value = "x"*256

    put admin_site_settings_path, params: {
      settings: {
        cc_terms_path: long_value,
        cc_privacy_path: long_value,
        cc_refunds_path: long_value
      }
    }

    assert_response :success
    assert_template :edit
    assert_equal "Settings could not be updated", flash[:danger]

    page = Nokogiri::HTML4::Document.parse(response.body)
    errors = page.xpath("//p[@class='pf-c-form__helper-text pf-m-error']")

    assert_equal 3, errors.length
    assert_equal ["is too long (maximum is 255 characters)"], errors.map(&:text).uniq
  end
end
