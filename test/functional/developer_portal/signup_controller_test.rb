require 'test_helper'

class DeveloperPortal::SignupControllerTest < DeveloperPortal::ActionController::TestCase
  disable_transactional_fixtures!
  def setup
    super
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.first_service!

    @request.host = @provider.domain
  end

  test 'should redirect out logged in users' do
    login_as(@provider.admins.first)
    get :show
    assert_redirected_to '/admin'
  end

  test '#create should login if the user can login' do
    User.any_instance.expects(:can_login?).returns(true)
    post :create, valid_buyer_params
    assert @controller.send(:current_user)
  end

  test '#create should send the confirmation email without the activation link' do
    auth_provider = FactoryBot.create(:authentication_provider, account: @provider)

    deliveries = ActionMailer::Base.deliveries
    deliveries.clear

    session[:authentication_id] = 'A1234'
    session[:authentication_provider] = auth_provider.system_name
    # First check that the confirmation link is send
    post :create, valid_buyer_params
    assert_response :redirect

    mail = deliveries.last
    assert_match(/activate/, mail.body.to_s)
    assert_equal valid_buyer_params[:account][:user][:email], mail.to[0]
    assert_match(/API account confirmation/, mail.subject)
    Account.last.destroy!
    deliveries.clear

    # Now check that the link is not send
    session[:authentication_id] = 'A1234'
    session[:authentication_provider] = auth_provider.system_name
    session[:authentication_email] = valid_buyer_params[:account][:user][:email]
    post :create, valid_buyer_params
    assert_response :redirect

    mail = deliveries.last
    assert_equal valid_buyer_params[:account][:user][:email], mail.to[0]
    assert_match(/API account confirmation/, mail.subject)
    refute_match(/activate/, mail.body.to_s)
  end

  test '#create should track the signup if success' do
    ThreeScale::Analytics.expects(:track).with(@provider.first_admin, 'Acquired new Developer Account', kind_of(Hash))
    post :create, valid_buyer_params
  end

  test '#create successfully from oauth2 should save the id_token' do
    auth_provider = FactoryBot.create(:keycloak_authentication_provider, account: @provider)
    session[:id_token] = 'fake-token'
    session[:authentication_id] = 'foo'
    session[:authentication_provider] = auth_provider.system_name
    session[:authentication_kind] = auth_provider.kind
    post :create, valid_buyer_params
    assert_equal 'fake-token', User.last.sso_authorizations.last.id_token
  end

  context "with all default plans" do
    setup do
      @provider.update_attribute :default_account_plan,  FactoryBot.create(:account_plan, :issuer => @provider)
      @service.update_attribute :default_service_plan,  FactoryBot.create(:service_plan, :issuer => @service)
      @service.update_attribute :default_application_plan,  FactoryBot.create(:application_plan, :issuer => @service)
    end

    # making sure create doesn't crash with an empty post, some browsers are weird
    should "work with empty post" do
      post :create
      assert_response :success
    end

    should "push webhooks" do
      #TODO: improve this by asserting the parameters
      WebHook::Event.expects(:enqueue).times(3)

      post :create, valid_buyer_params
    end
  end

  context "without any default plan" do
    setup do
      @provider.update_attribute :default_account_plan,  nil
    end

    should "not create account" do
      post :create, valid_buyer_params

      signup_result = assigns(:signup_result)

      assert_includes signup_result.errors[:plans], 'Account plan is required'
      refute signup_result.valid?
      assert signup_result.user.valid?
    end
  end

  should "raise RecordNotFound with wrong plan ids" do
    post :create, valid_buyer_params(:plans => [1, 2])
    assert_response :not_found
  end

  context "provider with multiple services and service plans" do
    setup do
      @service_two = @provider.services.create :name => "Second"
      @service_two_plan = FactoryBot.create(:service_plan, :issuer => @service)
      @service_two_plan_two = FactoryBot.create(:service_plan, :issuer => @service)

      [@service_two_plan, @service_two_plan_two].each &:publish!
    end

    should "allow only one service subsription" do
      post :create, valid_buyer_params(:plans => [@service_two_plan_two, @service_two_plan].map(&:id))
      signup_result = assigns(:signup_result)

      assert_includes signup_result.errors[:plans], 'Can subscribe only one plan per service'
    end
  end

  private

  def valid_buyer_params(hash = {})
    { :account => { :org_name => "bar",
               :user => { :username => "foobar", :email => "email@email.com",
                 :password => "123456", :password_confirmation => "123456" } }}.merge(hash)
  end
end
