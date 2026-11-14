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
    assert_equal I18n.t('sites.settings.update.success'), flash[:success]

    provider.settings.reload
    assert_equal '/terms', provider.settings.cc_terms_path
    assert_equal '/privacy', provider.settings.cc_privacy_path
    assert_equal '/refunds', provider.settings.cc_refunds_path
  end

  test 'update with empty values shows errors' do
    provider = FactoryBot.create(:provider_account)
    login_provider provider

    put admin_site_settings_path, params: {
      settings: {
        cc_terms_path: '',
        cc_privacy_path: '',
        cc_refunds_path: ''
      }
    }

    assert_response :success
    assert_template :edit
    assert_equal I18n.t('sites.settings.update.error'), flash[:danger]

    page = Nokogiri::HTML4::Document.parse(response.body)
    errors = page.xpath("//p[@class='pf-c-form__helper-text pf-m-error']")

    assert_equal 3, errors.length
    assert_equal [I18n.t('errors.messages.blank')], errors.map(&:text).uniq
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
    assert_equal I18n.t('sites.settings.update.error'), flash[:danger]

    page = Nokogiri::HTML4::Document.parse(response.body)
    errors = page.xpath("//p[@class='pf-c-form__helper-text pf-m-error']")

    assert_equal 3, errors.length
    assert_equal [I18n.t('errors.messages.too_long', count: 255)], errors.map(&:text).uniq
  end
end
