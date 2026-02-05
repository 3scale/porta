require 'test_helper'

class CMS::ToolbarTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    SimpleLayout.new(@provider).import!
  end

  test 'CMS toolbar rendering' do
    provider_id = @provider.id
    expires_at = Time.now.utc.round + 1.minute
    signature = CMS::Signature.generate(provider_id, expires_at)
    host! @provider.internal_domain

    get "/", params: { expires_at: expires_at.to_i, signature: }
    assert_response :success

    get '/api_docs/login'
    assert_response :success

    login_with @buyer.admins.first.username, "superSecret1234#"

    get '/admin'
    assert_response :success

    page = Nokogiri::HTML4::Document.parse(response.body)
    assert_equal 1, page.css('iframe#developer-portal').size
    [ 'Layout Main layout', 'Partial Submenu' ].each do |template|
      assert_not_empty page.css("#templates-list a:contains('#{template}')"), "could not find: #{template.inspect} in #{page.text}"
    end
  end

end
