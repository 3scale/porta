require 'test_helper'

class Admin::Api::BuyersApplicationsControllerTest < ActionController::TestCase

  def setup
    provider = FactoryBot.create(:provider_account)
    @service  = FactoryBot.create(:service, account: provider)
    @plan    = FactoryBot.create(:application_plan, service: @service)
    @buyer   = FactoryBot.create(:buyer_account, provider_account: provider)

    host! provider.admin_domain

    login_provider provider
  end

  def test_index
    get :index, account_id: @buyer.id, format: :xml

    assert_response :success
  end

  def test_create
    post :create, account_id: @buyer.id, plan_id: @plan.id, format: :xml

    assert_response :success
  end

  def test_delete
    application = FactoryBot.create(:cinstance, user_account: @buyer, service: @service)

    delete :destroy, account_id: @buyer.id, id: application.id, format: :xml

    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { application.reload }
  end

  def test_create_raise_error
    params = {
      application_id: 'cba0c140',
      account_id:     @buyer.id,
      plan_id:        @plan.id,
      format:         :xml
    }

    post :create, params

    assert_response :success

    # second time responds with errors instead of raising
    post :create, params

    assert_response :unprocessable_entity
  end
end
