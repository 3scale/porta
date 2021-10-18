# frozen_string_literal: true

require 'test_helper'

module CMS
  class PagesTest < ActionDispatch::IntegrationTest

    def setup
      @provider = FactoryBot.create(:provider_account)
      login_provider @provider
    end

    test 'update - without layout' do
      new_layout = FactoryBot.create(:cms_layout, system_name: 'NEW', provider: @provider)
      page = FactoryBot.create(:cms_page, provider: @provider, layout: new_layout)

      patch provider_admin_cms_page_path(page), params: { provider_key: @provider.provider_key, id: page.id, format: :js, cms_template: {
        title: 'new title',
        content_type: 'text/xml',
        layout_id: ''
      } }

      assert_response :success

      page.reload
      assert_equal 'new title', page.title
      assert_equal 'text/xml', page.content_type
      assert_nil page.layout
    end

  end
end
