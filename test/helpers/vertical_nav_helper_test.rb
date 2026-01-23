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
      @current_user = FactoryBot.create(:simple_admin, account: current_account)
    end

    test '#backend_api_nav_sections' do
      @backend_api = FactoryBot.create(:backend_api)

      # if permitted
      assert_equal(["Backend Overview", "Analytics", "Methods and Metrics", "Mapping Rules"], backend_api_nav_sections.pluck(:title))

      # if not permitted
      stubs(can?: false)
      assert_equal(["Backend Overview"], backend_api_nav_sections.pluck(:title))

      # When backend_api is not persisted
      @backend_api = BackendApi.new
      assert_equal([], backend_api_nav_sections.pluck(:title))

      # When backend_api is nil
      @backend_api = nil
      assert_equal([], backend_api_nav_sections.pluck(:title))
    end

    test '#service_nav_sections' do
      plan = FactoryBot.create(:application_plan)
      @service= FactoryBot.create(:service)

      # if permitted
      VerticalNavHelperTest::ProviderTest.any_instance.stubs(:out_of_date_config?).returns(false)
      assert_equal(["Product Overview", "Analytics", "Applications", "ActiveDocs", "Integration"], service_nav_sections.pluck(:title))

      # if not permitted
      stubs(can?: false)
      assert_equal([], service_nav_sections.pluck(:title))

     # When service is not persisted
      @service = Service.new
      assert_equal([], service_nav_sections.pluck(:title))


      # When service is nil
      @service = nil
      assert_equal([], service_nav_sections.pluck(:title))
    end

    test '#audience_nav_sections' do
      # admin
      assert_equal(["Accounts", "Applications", "Billing", "Developer Portal", "Messages"], audience_nav_sections.pluck(:title))

      # member that can't manage portal, settings and plans
      stubs(:can?).with(:manage, :portal).returns(false)
      stubs(:can?).with(:manage, :settings).returns(false)
      stubs(:can?).with(:manage, :plans).returns(false)
      assert_equal(%w[Accounts Applications Billing Messages], audience_nav_sections.pluck(:title))
    end

    test '#audience_portal_items' do
      assert_equal(["Content", "Drafts", "Redirects", "Groups", "Logo", "Feature Visibility", "ActiveDocs", "Visit Portal", "Legal Terms", "Settings", "Docs"], audience_portal_items.pluck(:title).compact)

      stubs(:can?).with(:see, :groups).returns(false)
      assert_not_includes audience_portal_items.pluck(:title), "Groups"

      stubs(:can?).with(:update, :logo).returns(false)
      assert_not_includes audience_portal_items.pluck(:title), "Logo"

      stubs(:can?).with(:manage, :plans).returns(false)
      assert_not_includes audience_portal_items.pluck(:title), "ActiveDocs"

      stubs(:can?).with(:manage, :portal).returns(false)
      assert_equal(%w[Settings Docs], audience_portal_items.pluck(:title).compact)
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
