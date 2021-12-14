# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Buyer::StatsControllerTest < DeveloperPortal::ActionController::TestCase
  def setup
    super
    @provider = FactoryBot.create(:provider_account)
    @request.host = @provider.domain
  end

  class BeforeLoginTest < DeveloperPortal::Buyer::StatsControllerTest
    test 'login is required' do
      get :index
      assert_redirected_to login_url
    end
  end

  class AfterLoginTest < DeveloperPortal::Buyer::StatsControllerTest
    def setup
      super
      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @app_plan = FactoryBot.create(:application_plan, issuer: @provider.default_service)

      login_as(@buyer.admins.first)
    end

    class BuyerWithoutLiveCinstancesTest < AfterLoginTest
      def setup
        super
        app = @buyer.buy! @app_plan
        app.suspend!
      end

      test "be redirected to applications" do
        get :index
        assert_redirected_to admin_applications_url
      end
    end

    class IndexMethodTest < AfterLoginTest
      def setup
        super
        @live_app1 = @buyer.buy! @app_plan
        @live_app2 = @buyer.buy! FactoryBot.create(:application_plan, issuer: @provider.default_service)
        cinstance = @buyer.buy! FactoryBot.create(:application_plan, issuer: @provider.default_service)
        cinstance.suspend!
      end

      test '#index only returns live cinstances' do
        get :index

        doc = Nokogiri::HTML.parse(response.body)
        assert_equal [@live_app1, @live_app2], assigns(:applications)
        assert_equal @live_app1.id.to_s, doc.css('#client-name[data-client]').attr('data-client').value
      end

      test '#index with multiapps visible' do
        @provider.settings.allow_multiple_applications!
        @provider.settings.show_multiple_applications!

        get :index

        doc = Nokogiri::HTML.parse(response.body)
        assert_equal @live_app1.id.to_s, doc.css('#client-name[data-client]').attr('data-client').value
      end

      test '#index returns first live cinstance as default' do
        get :index
        assert_equal @live_app1, @controller.instance_variable_get('@cinstance')
      end
    end

    class MetricsActionTest < AfterLoginTest
      def setup
        super
        @live_app1 = @buyer.buy! @app_plan
        @hits = @provider.default_service.metrics.first

        disabled_metric = FactoryBot.create(:metric, service: @provider.default_service)
        disabled_metric.disable_for_plan @app_plan

        hidden_metric = FactoryBot.create(:metric, service: @provider.default_service)
        hidden_metric.toggle_visible_for_plan(@app_plan)
      end

      test '#metrics only return enabled and visible metrics in app plan' do
        get :metrics_list, params: { id: @live_app1.id }
        assert_equal [@hits], assigns(:metrics)
      end

      test '#metrics return 404 for non-existent app' do
        get :metrics_list, params: { id: 'NON_EXISTENT' }
        assert_response :not_found
      end
    end

    class MethodsActionTest < AfterLoginTest
      def setup
        super
        @live_app1 = @buyer.buy! @app_plan
        @hits = @provider.default_service.metrics.first

        @method = @hits.children.create!(system_name: "method", friendly_name: "method")
        disabled_method = @hits.children.create!(system_name: "disabled", friendly_name: "disabled")
        disabled_method.disable_for_plan @app_plan

        hidden_method = @hits.children.create!(system_name: "hidden", friendly_name: "hidden")
        hidden_method.toggle_visible_for_plan(@app_plan)
      end

      test '#methods only return enabled and visible methods in app plan' do
        get :methods_list, params: { id: @live_app1.id }
        assert_equal [@method], assigns(:methods)
      end
    end
  end
end
