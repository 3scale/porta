require 'test_helper'

class Liquid::RenderingTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

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

  test 'message navigation renders the inbox and sent routes for an authenticated buyer' do
    assert_equal '/admin/messages/received', admin_messages_inbox_index_path
    assert_equal '/admin/messages/sent', admin_messages_outbox_index_path
    assert_equal '/admin/messages/new', admin_messages_new_path

    get admin_messages_root_path
    assert_redirected_to admin_messages_inbox_index_path

    [admin_messages_inbox_index_path, admin_messages_outbox_index_path].each do |path|
      get path
      assert_response :success
      assert_select 'a[href$=?]', admin_messages_inbox_index_path
      assert_select 'a[href$=?]', admin_messages_outbox_index_path
      assert_select 'a[href$=?]', admin_messages_new_path
    end
  end
end
