require 'test_helper'

module CMS

  class PageTitleTest < ActionDispatch::IntegrationTest

    def setup
      @provider = FactoryBot.create(:provider_account, org_name: 'lalala')
      @simple_layout = SimpleLayout.new(@provider)
      @main_layout = @simple_layout.setup_main_layout!
      @root_section = @provider.sections.root
      @provider.name = 'lalala'

      host! @provider.domain
    end

    test 'page has default title' do
      page = @provider.pages.create(path: '/foo', layout: @main_layout, section: @root_section)
      page.published = 'some content'
      page.save(validate: false)

      get '/foo'

      assert_select 'title', @provider.name
    end

    test 'page has title' do
      page = @provider.pages.new(path: '/foo', title: 'Page title', layout: @main_layout, section: @root_section)
      page.published = 'some content'
      page.save(validate: false)

      get '/foo'
      assert_response :success
      assert_select 'title', 'Page title'
    end
  end
end
