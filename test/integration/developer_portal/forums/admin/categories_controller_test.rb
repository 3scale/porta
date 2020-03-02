# frozen_string_literal: true

require 'test_helper'

module DeveloperPortal
  class Forums::Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
    include System::UrlHelpers.cms_url_helpers

    def setup
      @provider = FactoryBot.create(:provider_account)
      provider.settings.allow_multiple_applications!
      provider.settings.show_multiple_applications!
      provider.settings.update_column(:forum_enabled, true)
      @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      @category = provider.forum.categories.create!(name: 'Security')
      login_buyer buyer
    end

    attr_reader :provider, :buyer, :category

    test '#create' do
      assert_raises(::ActionController::RoutingError) { post admin_forum_categories_path({topic_category: {name: 'fake'}}) }
    end

    test '#update' do
      assert_raises(::ActionController::RoutingError) { put admin_forum_category_path(category) }
    end

    test '#delete' do
      assert_raises(::ActionController::RoutingError) { delete admin_forum_category_path(category) }
    end
  end
end
