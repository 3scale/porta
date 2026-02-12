require 'test_helper'

class MessagesTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create :provider_account
    @buyer = FactoryBot.create :buyer_account, :provider_account => @provider
    host! @provider.external_admin_domain
    provider_login_with @provider.admins.first, 'superSecret1234#'
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
