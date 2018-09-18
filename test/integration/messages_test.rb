require 'test_helper'

class MessagesTest < ActionDispatch::IntegrationTest

  def setup
    @provider = Factory :provider_account
    @buyer = Factory :buyer_account, :provider_account => @provider
    host! @provider.admin_domain
    provider_login_with @provider.admins.first, 'supersecret'
  end

  test "ensure buyer domain" do
    assert_raises(ActionController::RoutingError) do
      get '/admin/messages/outbox'
    end

    assert_raises(ActionController::RoutingError) do
      get '/admin/messages/inbox'
    end

    assert_raises(ActionController::RoutingError) do
      get '/admin/messages/trash'
    end
  end

end
