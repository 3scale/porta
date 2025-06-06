require 'test_helper'

class Provider::Admin::Messages::InboxControllerTest < ActionController::TestCase

  def setup
    account  = FactoryBot.create(:provider_account)
    @message = FactoryBot.create(:received_message, receiver: account)

    host! account.internal_admin_domain

    @member = FactoryBot.create(:member)
    account.users << @member
    @admin = account.admins.first
  end

  def test_index_not_system_message
    login_as(@admin)

    get :index

    assert_response :success
    assert_equal 1, assigns(:messages).count
  end

  def test_index_system_message
    login_as(@admin)

    @message.message.update system_operation_id: 1

    get :index

    assert_response :success
    assert_equal 0, assigns(:messages).count
  end

  test 'renders index page' do
    login_as(@admin)
    get :index
    assert_response :success
    assert_select 'title', "Inbox - Index | Red Hat 3scale API Management"
  end

  test 'renders index page without export option for members' do
    login_as @member
    get :index
    assert_response :success
    assert_select 'title', "Inbox - Index | Red Hat 3scale API Management"
    assert_select '#export-to-csv', false, 'Export all Messages'
  end

  test 'creates valid reply' do
    login_as(@admin)
    post :reply, params: { message: { subject: "Valid Message", body: "message with subject" }, id: @message.id }

    MessageWorker.drain
    msg = Message.last

    assert_equal 'Reply was sent', flash[:success]
    assert 'sent', msg.state
    assert_equal 'message with subject', msg.body
  end

  test 'not creates invalid message' do
    login_as(@admin)
    post :reply, params: { message: { subject: nil, body: 'message with nil subject' }, id: @message.id }

    MessageWorker.drain
    msg = Message.last
    assert_not_equal 'message with nil subject', msg.body
  end
end
