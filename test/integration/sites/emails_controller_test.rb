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

end
