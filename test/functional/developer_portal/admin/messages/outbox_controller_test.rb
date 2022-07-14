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

    host! provider.domain

    login_as @user
  end

  test "creates messages with origin == 'web'" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider

    post :create, params: { message: { :subject => "message via web", :body => "message via web" }, :to => buyer.id }

    MessageWorker.drain
    assert msg = Message.last
    assert_equal "web", msg.origin
  end

   test "will not create messages without subject and body" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider

    msg = Message.new
    msg.sender_id = buyer.id
    msg.subject = ""
    msg.body = ""
    assert !msg.valid?
  end

  test "will create messages with subject and body" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider

    msg = Message.new
    msg.sender_id = buyer.id
    msg.subject = "I am subject"
    msg.body = "I am body"
    assert msg.valid?
  end

  test "will not create messages with only subject" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider

    msg = Message.new
    msg.sender_id =  buyer.id
    msg.subject = "it subject"
    msg.body =""
    assert !msg.valid?
  end

  test "will not create messages with only body" do
    buyer = FactoryBot.create :buyer_account, :provider_account => @provider

    msg = Message.new
    msg.sender_id = buyer.id
    assert !msg.valid?
  end

  def test_index
    get :index

    assigned_drop_variables = assigns(:_assigned_drops).keys

    assert :success
    assert assigned_drop_variables.include?('messages')
    assert assigned_drop_variables.include?('pagination')
  end
end
