require 'test_helper'

class Api::ServicesControllerTest < ActionController::TestCase

  def setup
    @provider  = FactoryBot.create(:provider_account)
    @service   = FactoryBot.create(:service, account: @provider)
    member     = FactoryBot.create(:member, account: @provider)
    permission = FactoryBot.create(:member_permission, admin_section: :plans)

    member.member_permissions << permission

    @request.host = @provider.domain

    login_as member
  end

  def test_load_and_authorize_resource
    get :show, id: FactoryBot.create(:service).id

    assert_response 404
  end

  def test_show
    get :show, id: @service.id

    assert_response 200
  end

  def test_edit
    get :edit, id: @service.id

    assert_response 200
  end

  def test_settings
    get :settings, id: @service.id

    assert_response 200
  end

  test 'settings with finance allowed' do
    @provider.settings.finance.allow

    login_as @provider.admins.first
    get :settings, id: @service.id

    assert_select "input[name='service[buyer_plan_change_permission]'][value=credit_card]"
    assert_select "input[name='service[buyer_plan_change_permission]'][value=request_credit_card]"
  end

  test 'settings with finance denied' do
    @provider.settings.finance.deny

    login_as @provider.admins.first
    get :settings, id: @service.id

    assert_select "input[name='service[buyer_plan_change_permission]'][value=credit_card]", false
    assert_select "input[name='service[buyer_plan_change_permission]'][value=request_credit_card]", false
  end

  test 'settings with finance globally denied' do
    @provider = master_account
    @provider.settings.stubs(globally_denied_switches: [:finance])
    @provider.settings.finance.allow

    login_as @provider.admins.first
    get :settings, id: @service.id

    assert_select "input[name='service[buyer_plan_change_permission]'][value=credit_card]", 0
    assert_select "input[name='service[buyer_plan_change_permission]'][value=request_credit_card]", 0
  end

  def test_notifications
    get :settings, id: @service.id

    assert_response 200
  end

  # regression of https://3scale.airbrake.io/errors/53365879
  def test_update_handles_missing_referrer
    put :update, id: @service.id

    assert_response 302
  end

  def test_service_create_should_change_api_bubble_state
    @provider.create_onboarding

    @controller.stubs(:authorize_plans)
    @controller.stubs(:can_create?).returns(true)

    post :create, service: { name: 'Test bubbles' }

    assert_response 302
    assert_equal 'api_done', @provider.reload.onboarding.bubble_api_state
  end

  def test_update
    assert_not_equal @service.name, 'Supetramp'

    put :update, id: @service.id, service: { name: 'Supetramp' }

    @service.reload

    assert_equal @service.name, 'Supetramp'
    assert_response 302
  end

  def test_not_success_update
    Service.any_instance.stubs(update_attributes: false)

    put :update, id: @service.id, service: { name: 'Supetramp' }

    assert_response 200
  end
end
