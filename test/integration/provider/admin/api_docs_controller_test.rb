# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ApiDocsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login! FactoryBot.create(:provider_account)
  end

  test 'show activates the proper menus' do
    get provider_admin_api_docs_path
    active_menus = assigns(:active_menus)
    assert_equal({main_menu: :account, submenu: :integrate, sidebar: :apidocs, topmenu: :dashboard}, active_menus)
  end
end
