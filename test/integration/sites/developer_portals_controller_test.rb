# frozen_string_literal: true

require 'test_helper'

class Sites::DeveloperPortalsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
  end

  test 'edit shows developer portal settings' do
    get edit_admin_site_developer_portal_path

    assert_response :success
    assert_match 'Cross-Site Scripting Protection', response.body
  end

  test 'update to enable both settings' do
    put admin_site_developer_portal_path, params: {
      settings: {
        cms_escape_draft_html: '1',
        cms_escape_published_html: '1'
      }
    }

    assert_redirected_to edit_admin_site_developer_portal_path
    assert_equal 'Developer Portal settings updated', flash[:success]

    @provider.settings.reload
    assert @provider.settings.cms_escape_draft_html?
    assert @provider.settings.cms_escape_published_html?
  end

  test 'update to disable both settings' do
    @provider.settings.update(cms_escape_draft_html: true, cms_escape_published_html: true)

    put admin_site_developer_portal_path, params: {
      settings: {
        cms_escape_draft_html: '0',
        cms_escape_published_html: '0'
      }
    }

    assert_redirected_to edit_admin_site_developer_portal_path
    assert_equal 'Developer Portal settings updated', flash[:success]

    @provider.settings.reload
    assert_not @provider.settings.cms_escape_draft_html?
    assert_not @provider.settings.cms_escape_published_html?
  end

  test 'update with invalid params shows error' do
    Settings.any_instance.stubs(:update).returns(false)

    put admin_site_developer_portal_path, params: {
      settings: {
        cms_escape_draft_html: true
      }
    }

    assert_response :success
    assert_template :edit
    assert_equal 'There were problems saving the settings', flash[:danger]
  end
end
