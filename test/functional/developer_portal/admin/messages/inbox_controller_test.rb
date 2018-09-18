require 'test_helper'

class DeveloperPortal::Admin::Messages::InboxControllerTest < DeveloperPortal::ActionController::TestCase
  with_options(:controller => 'messages/inbox') do |test|
    test.should route(:get, '/admin/messages/received').to :action => 'index'
    test.should route(:get, '/admin/messages/received/42').to :action => 'show', :id => '42'
    test.should route(:post, '/admin/messages/received').to :action => 'create'
    test.should route(:delete, '/admin/messages/received/42').to :action => 'destroy', :id => '42'
  end

  test "creates messages replies with origin == 'web'" do
    @provider = Factory :provider_account
    @buyer    = Factory :buyer_account, :provider_account => @provider
    message   = Message.create!(:sender => @provider, :to => [@buyer], :subject => 'buyer', :body => "buyer", :origin => "web")
    message.deliver!
    @request.host = @provider.domain
    login_as(@buyer.admins.first)

    post :create, :reply_to => message.recipients.first.id, :message => { :subject => "reply via web", :body => "reply via web" }

    msg = Message.last
    assert_equal "web", msg.origin
    assert_equal "reply via web", msg.subject
  end
end
