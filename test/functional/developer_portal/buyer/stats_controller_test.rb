require 'test_helper'

class DeveloperPortal::Buyer::StatsControllerTest < DeveloperPortal::ActionController::TestCase
  disable_transactional_fixtures!

  def setup
    super
    @provider = FactoryBot.create :provider_account
    @request.host = @provider.domain
  end

  test 'login is required' do
    get :index
    assert_redirected_to login_url
  end

  context "buyer without live cinstances" do
    setup do
      @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
      @app_plan = FactoryBot.create(:application_plan, :issuer => @provider.default_service)
      app = @buyer.buy! @app_plan
      app.suspend!

      login_as(@buyer.admins.first)
    end

    should "be redirected to applications" do
      get :index
      assert_redirected_to admin_applications_url
    end
  end

  context "resources for buyers" do
    setup do
      @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
      @app_plan = FactoryBot.create(:application_plan, :issuer => @provider.default_service)
      @live_app1 = @buyer.buy! @app_plan
      @hits = @provider.default_service.metrics.first

      login_as(@buyer.admins.first)
    end

    context "#index action" do
      setup do
        app_plan2 = FactoryBot.create(:application_plan, :issuer => @provider.default_service)
        app_plan3 = FactoryBot.create(:application_plan, :issuer => @provider.default_service)
        @live_app2 = @buyer.buy! app_plan2
        cinstance = @buyer.buy! app_plan3
        cinstance.suspend!
      end

      should 'only return live cinstances' do
        get :index

        doc = Nokogiri::HTML.parse(response.body)
        assert_equal [@live_app1, @live_app2], @controller.instance_variable_get('@cinstances')
        assert_equal @live_app1.id.to_s,  doc.css('#client-name[data-client]').attr('data-client').value
      end

      should 'with multiapps visible' do
        @provider.settings.allow_multiple_applications!
        @provider.settings.show_multiple_applications!

        get :index

        doc = Nokogiri::HTML.parse(response.body)
        assert_equal @live_app1.id.to_s, doc.css('#client-name[data-client]').attr('data-client').value
      end

      should 'return first live cinstance as default' do
        get :index
        #assert_equal @live_app1, assigns(:cinstance)
        assert_equal @live_app1, @controller.instance_variable_get('@cinstance')
      end
    end # index action

    context "#metrics action" do
      setup do
        disabled_metric = FactoryBot.create(:metric, :service => @provider.default_service)
        disabled_metric.disable_for_plan @app_plan
        assert disabled_metric.disabled_for_plan?(@app_plan) #being paranoid about initial state

        hidden_metric = FactoryBot.create(:metric, :service => @provider.default_service)
        hidden_metric.toggle_visible_for_plan(@app_plan)
        assert !hidden_metric.visible_in_plan?(@app_plan) #being paranoid about initial state
      end

      should 'only return enabled and visible metrics in app plan' do
        get :metrics_list, :id => @live_app1.id
        assert_equal [@hits], assigns(:metrics)
      end

      should 'return 404 for non-existent app' do
        get :metrics_list, :id => 'NON_EXISTENT'
        assert_response :not_found
      end

    end # metrics action

    context "#methods action" do
      setup do
        @method = @hits.children.create! :system_name => "method", :friendly_name => "method"
        disabled_method = @hits.children.create! :system_name => "disabled", :friendly_name => "disabled"
        disabled_method.disable_for_plan @app_plan
        assert disabled_method.disabled_for_plan?(@app_plan) #being paranoid about initial state

        hidden_method = @hits.children.create! :system_name => "hidden", :friendly_name => "hidden"
        hidden_method.toggle_visible_for_plan(@app_plan)
        assert !hidden_method.visible_in_plan?(@app_plan) #being paranoid about initial state
      end

      should 'only return enabled and visible methods in app plan' do
        get :methods_list, :id => @live_app1.id
        assert_equal [@method], assigns(:methods)
      end
    end # methods action
  end # buyer resources
end
