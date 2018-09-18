require 'test_helper'

class Liquid::RenderingTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory(:simple_provider)
    @buyer = Factory(:simple_buyer, provider_account: @provider)
    @user = Factory(:simple_user, account: @buyer, role: :admin)
    @user.activate!

    login_buyer(@buyer)
  end

  test 'rendering partial with prefix does not render partial without prefix' do
    @provider.partials.create!(system_name: 'menu')

    get '/admin/messages/received'
    assert_response :success

    assert_select 'a', text: 'Compose'
    assert_select 'a', text: 'Inbox'
  end
end
