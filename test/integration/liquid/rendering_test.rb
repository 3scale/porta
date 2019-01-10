require 'test_helper'

class Liquid::RenderingTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
    @user = FactoryBot.create(:simple_user, account: @buyer, role: :admin)
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
