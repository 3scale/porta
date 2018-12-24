require 'test_helper'

module CMS

  class BuiltinPageTest < ActionDispatch::IntegrationTest
    def setup
      @provider = FactoryBot.create(:provider_account)
      host! @provider.domain
    end

    test 'builtin page has default layout' do
      get '/login'
      assert_template 'layouts/main_layout'
    end

    test 'builtin page has different layout' do
      @simple_layout = SimpleLayout.new(@provider)
      @simple_layout.import!

      @layout = @provider.layouts.create(system_name: 'custom_layout')
      builtin_page = @provider.builtin_pages.find_by_system_name!('login/new')
      builtin_page.update_attribute(:layout, @layout)

      get '/login'
      assert_template 'layouts/custom_layout'
    end

  end

end
