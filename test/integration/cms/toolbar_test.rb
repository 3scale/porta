require 'test_helper'

class CMS::ToolbarTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    SimpleLayout.new(@provider).import!
  end

  test 'CMS toolbar rendering' do
    host! @provider.domain

    get "/?cms_token=#{@provider.settings.cms_token!}"
    assert_response :success

    get '/api_docs/login'
    assert_response :success

    login_with @buyer.admins.first.username, "supersecret"

    get '/admin'
    assert_response :success

    page = Nokogiri::HTML::Document.parse(response.body)
    assert_equal 1, page.css('iframe#developer-portal').size
    [ 'Layout Main layout', 'Partial Submenu' ].each do |template|
      assert_not_empty page.css("#templates-list a:contains('#{template}')"), "could not find: #{template.inspect} in #{page.text}"
    end
  end

end
