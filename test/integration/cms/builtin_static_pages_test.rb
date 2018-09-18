require 'test_helper'

module CMS

  class BuiltinStaticPageTest < ActionDispatch::IntegrationTest
    def setup
      @provider = Factory(:provider_account)
      host! @provider.domain
    end

    test 'builtin static page has default layout' do
      get '/signup'
      assert_template 'layouts/main_layout'
    end

    test 'builtin static page has different layout' do
      @simple_layout = SimpleLayout.new(@provider)
      @simple_layout.import!

      @layout = @provider.layouts.create(system_name: 'custom_layout')
      static_page = @provider.builtin_static_pages.find_by_system_name!('forum/forums/show')
      static_page.update_attribute(:layout, @layout)

      get '/forum'
      assert_template 'layouts/custom_layout'
    end

  end

end
