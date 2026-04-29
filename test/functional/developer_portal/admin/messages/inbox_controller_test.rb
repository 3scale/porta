require 'test_helper'

class DeveloperPortal::Admin::Messages::InboxControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    provider = FactoryBot.create(:provider_account)
    @user    = FactoryBot.create(:user, account: provider)
    @message = FactoryBot.create(:received_message, receiver: provider)

    host! provider.internal_domain

    login_as @user
  end

  def test_index
    get :index

    assigned_drop_variables = assigns(:_assigned_drops).keys

    assert :success
    assert assigned_drop_variables.include?('messages')
    assert assigned_drop_variables.include?('pagination')
  end

  test 'creates valid reply' do
    post :create, params: { message: { body: "reply message" }, reply_to: @message.id }

    MessageWorker.drain
    msg = Message.last

    assert_equal 'Reply was sent.', flash[:notice]
    assert_equal "Re: #{@message.subject}", msg.subject
    assert_equal 'sent', msg.state
    assert_equal 'reply message', msg.body
  end
end
