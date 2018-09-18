require 'test_helper'

module CMS

  class ErrorHandlingTest < ActionDispatch::IntegrationTest
    def setup
      @provider = Factory(:provider_account)
      host! @provider.domain
    end

    test 'not_found is rendered from builtin page in DB' do
      sl= SimpleLayout.new(@provider)
      sl.setup_error_layout!
      sl.create_builtin_pages_and_partials!

      error_layout = @provider.layouts.find_by_system_name('error')
      error_layout.published = "<head><title>{{ page.title }}</title></head><body>{% content %}</body>"
      error_layout.save!

      not_found_page = @provider.builtin_pages.find_by_system_name('errors/not_found')
      not_found_page.published = 'FROM_DB'
      not_found_page.title = 'PAGE TITLE'
      not_found_page.layout = error_layout
      not_found_page.save!

      get '/i_am_not_there'

      assert_match /FROM_DB/, response.body
      # assert_match %r|<title>PAGE TITLE</title>|, response.body
    end

    test 'not_found with different layout' do
      sl= SimpleLayout.new(@provider)
      sl.create_builtin_pages_and_partials!

      layout = @provider.layouts.build(system_name: 'meta_layout')
      layout.published = "<h1>THINGS</h1><section>{% content %}</section>"
      layout.save!

      not_found_page = @provider.builtin_pages.find_by_system_name!('errors/not_found')
      not_found_page.layout = layout
      not_found_page.save!

      get '/i_am_not_here_either'

      assert_match %r|<h1>THINGS</h1>|, response.body
    end
  end
end
