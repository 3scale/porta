require 'test_helper'

class Provider::Admin::Messages::Bulk::TrashControllerTest < ActionController::TestCase

  def setup
    @provider         = FactoryBot.create(:provider_account)
    @received_message = FactoryBot.create(:received_message, receiver: @provider)
    @sent_message     = FactoryBot.create(:message, sender: @provider)

    host! @provider.admin_domain

    login_provider @provider
  end

  def test_new_received_message
    xhr :get, :new, received_messages_params

    assert_response :success
  end

  def test_new_sent_message
    xhr :get, :new, messages_params

    assert_response :success
  end

  def test_new_forbidden_scope
    assert_raise(Provider::Admin::Messages::Bulk::TrashController::ForbiddenAccountScope) do
      get :new, params_with_undefined_scope
    end
  end

  def test_hide_single_received_message
    assert_equal false, @received_message.hidden?

    post :create, received_messages_params

    @received_message.reload

    assert_response :success
    assert_equal true, @received_message.hidden?
    assert_equal 1, assigns(:message_ids).count
  end

  def test_hide_all_received_messages
    assert_equal false, @received_message.hidden?

    post :create, received_messages_params.merge(select_all_params)

    @received_message.reload

    assert_response :success
    assert_equal true, @received_message.hidden?
    assert_equal true, assigns(:no_more_messages)
  end

  def test_hide_single_sent_message
    assert_equal false, @sent_message.hidden?

    post :create, messages_params

    @sent_message.reload

    assert_response :success
    assert_equal true, @sent_message.hidden?
    assert_equal 1, assigns(:message_ids).count
  end

  def test_hide_all_sent_messages
    assert_equal false, @sent_message.hidden?

    post :create, messages_params.merge(select_all_params)

    @sent_message.reload

    assert_response :success
    assert_equal true, @sent_message.hidden?
    assert_equal true, assigns(:no_more_messages)
  end

  def test_blank_parameters
    assert_equal false, @sent_message.hidden?

    post :create, selected: [], selected_total_entries: '', scope: :messages, format: :js

    @sent_message.reload

    assert_equal false, @sent_message.hidden?
    assert_equal false, assigns(:no_more_messages)
  end

  def test_create_forbidden_scope
    assert_raise(Provider::Admin::Messages::Bulk::TrashController::ForbiddenAccountScope) do
      post :create, params_with_undefined_scope
    end
  end

  private

  def default_params
    { format: :js }
  end

  def messages_params
    default_params.merge({
      selected: [@sent_message.id],
      scope:    :messages
    })
  end

  def received_messages_params
    default_params.merge({
      selected: [@received_message.id],
      scope:    :received_messages
    })
  end

  def params_with_undefined_scope
    default_params.merge({
      selected: [@sent_message.id],
      scope:    'alaska_123'
    })
  end

  def select_all_params
    {
      selected:               [],
      selected_total_entries: true
    }
  end
end
