require 'test_helper'

class Provider::Admin::Messages::TrashControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryGirl.create(:provider_account)
    @message  = FactoryGirl.create(:received_message, receiver: @provider,
      hidden_at: DateTime.new(2015, 11, 11))

    host! @provider.admin_domain

    login_provider @provider
  end

  def test_index
    get :index

    assert_response :success
    assert_equal 1, assigns(:messages).count
  end

  def test_index_deleted_messages
    @message.update_attributes deleted_at: DateTime.new(2015, 11, 11)

    get :index

    assert_response :success
    assert_equal 0, assigns(:messages).count
  end

  def test_show
    get :show, id: @message.id

    assert_response :success
  end

  def test_show_deleted_message
    @message.update_attributes deleted_at: DateTime.new(2015, 11, 11)

    get :show, id: @message.id

    assert_response :not_found
  end

  def test_destroy
    assert_equal DateTime.new(2015, 11, 11), @message.hidden_at

    delete :destroy, id: @message.id

    @message.reload

    assert_response :redirect
    assert_equal nil, @message.hidden_at
  end

  def test_empty
    assert_not_equal 0, @provider.hidden_messages(:reload).count

    delete :empty

    assert_response :redirect
    assert_equal 0, @provider.hidden_messages(:reload).count
  end
end
