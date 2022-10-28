# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Messages::OutboxControllerTest < DeveloperPortal::ActionController::TestCase
  with_options :controller => 'messages/outbox' do |test|
    test.should route(:get, '/admin/messages/sent').to :action => 'index'
    test.should route(:get, '/admin/messages/new').to :action => 'new'
    test.should route(:post, '/admin/messages/sent').to :action => 'create'
    test.should route(:get, '/admin/messages/sent/42').to :action => 'show', :id => '42'
    test.should route(:delete, '/admin/messages/sent/42').to :action => 'destroy', :id => '42'
  end

  def setup
    provider = FactoryBot.create(:provider_account)
    @user    = FactoryBot.create(:user, account: provider)

    host! provider.internal_domain

    login_as @user
  end

  test "creates messages with origin == 'web'" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider

    post :create, params: { message: { :subject => "message via web", :body => "message via web" }, :to => buyer.id }

    MessageWorker.drain
    assert msg = Message.last
    assert_equal "web", msg.origin
  end

  def test_index
    get :index

    assigned_drop_variables = assigns(:_assigned_drops).keys

    assert :success
    assert assigned_drop_variables.include?('messages')
    assert assigned_drop_variables.include?('pagination')
  end

  test "not creates invalid message" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider
    post :create, params: { message: { subject: nil, :body => "message with nil subject" }, :to => buyer.id }

    MessageWorker.drain
    assert msg = Message.last
    assert_not_equal "message with nil subject", msg.body
  end

  test "creates valid message" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider
    post :create, params: { message: { subject: "Valid Message", :body => "message with subject" }, :to => buyer.id }

    MessageWorker.drain
    assert msg = Message.last
    assert_equal "message with subject", msg.body
  end
end
