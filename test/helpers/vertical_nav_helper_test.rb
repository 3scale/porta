# frozen_string_literal: true

require 'test_helper'

class VerticalNavHelperTest < ActionView::TestCase
  def setup
    stubs(can?: true, edit_legal_terms_url: '', logged_in?: '', user_has_subscriptions?: true)
  end

  attr_reader :current_account, :current_user

  delegate :provider_can_use?, :master_on_premises?, to: :current_account

  class ProviderTest < VerticalNavHelperTest
    def setup
      super
      @current_account = FactoryBot.create(:simple_provider)
      @current_user = FactoryBot.create(:simple_user, account: current_account)
    end

    test '#backend_api_nav_sections' do
      @backend_api = FactoryBot.create(:backend_api)

      # if permitted
      assert_equal(["Overview", "Analytics", "Methods and Metrics", "Mapping Rules"], backend_api_nav_sections.pluck(:title))

      # if not permitted
      stubs(can?: false)
      assert_equal(["Overview", "Methods and Metrics", "Mapping Rules"], backend_api_nav_sections.pluck(:title))

      # When backend_api is not persisted
      @backend_api = BackendApi.new
      assert_equal([], backend_api_nav_sections.pluck(:title))

      # When backend_api is nil
      @backend_api = nil
      assert_equal([], backend_api_nav_sections.pluck(:title))
    end

    test 'Forum is disabled in saas' do
      rolling_update(:forum, enabled: true)

      current_account.settings.forum_enabled = false
      assert_includes audience_portal_items.pluck(:id), :forum_settings
      assert_not_includes audience_nav_sections.pluck(:id), :forum

      current_account.settings.forum_enabled = true
      assert_not_includes audience_portal_items.pluck(:id), :forum_settings
      assert_includes audience_nav_sections.pluck(:id), :forum

      rolling_update(:forum, enabled: false)

      current_account.settings.forum_enabled = false
      assert_not_includes audience_portal_items.pluck(:id), :forum_settings
      assert_not_includes audience_nav_sections.pluck(:id), :forum

      current_account.settings.forum_enabled = true
      assert_not_includes audience_portal_items.pluck(:id), :forum_settings
      assert_not_includes audience_nav_sections.pluck(:id), :forum
    end

    test 'Email configurations' do
      Features::EmailConfigurationConfig.stubs(enabled?: true)
      assert_not_includes account_nav_sections.pluck(:id), :email_configurations

      Features::EmailConfigurationConfig.stubs(enabled?: false)
      assert_not_includes account_nav_sections.pluck(:id), :email_configurations
    end
  end

  class MasterTest < VerticalNavHelperTest
    alias current_account master_account

    def setup
      super
      @current_account = master_account
      @current_user = FactoryBot.create(:simple_user, account: current_account)
    end

    test 'Email configurations' do
      Features::EmailConfigurationConfig.stubs(enabled?: true)
      assert_includes account_nav_sections.pluck(:id), :email_configurations

      Features::EmailConfigurationConfig.stubs(enabled?: false)
      assert_not_includes account_nav_sections.pluck(:id), :email_configurations
    end
  end
end
