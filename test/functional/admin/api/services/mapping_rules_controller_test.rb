require 'test_helper'

module Admin::Api::Services
  class MappingRulesControllerTest < ActionController::TestCase
    def setup
      provider = FactoryGirl.create(:provider_account)
      assert @service = provider.first_service!
      assert @proxy = @service.proxy

      host! provider.admin_domain
      login_provider provider
    end

    def test_index_json
      @proxy.proxy_rules.create!(http_method: 'GET', pattern: '/', delta: 2, metric_id: @service.metrics.first!.id)
      get :index, { service_id: @service.id, format: :json }
      assert_response :success

      mapping_rules = JSON.parse(@response.body).fetch('mapping_rules')
          .map{|obj| obj.fetch('mapping_rule') }

      assert_equal 2, mapping_rules.size
    end

    def test_index_xml
      @proxy.proxy_rules.create!(http_method: 'GET', pattern: '/', delta: 2, metric_id: @service.metrics.first!.id)
      get :index, { service_id: @service.id, format: :xml }

      assert_response :success
      mapping_rules = Hash.from_xml(@response.body).fetch('mapping_rules').fetch('mapping_rule')
      assert_equal 2, mapping_rules.size
    end

    def test_show_json
      get :show, { id: @service.proxy.proxy_rules.first!, service_id: @service.id, format: :json }
      assert_response :success

      mapping_rule = JSON.parse(@response.body).fetch('mapping_rule')
      assert mapping_rule
    end

    def test_show_json_without_proxy_pro
      Service.any_instance.expects(:using_proxy_pro?).returns(false).at_least_once

      get :show, { id: @service.proxy.proxy_rules.first!, service_id: @service.id, format: :json }
      assert_response :success

      assert mapping_rule = JSON.parse(@response.body).fetch('mapping_rule')
      # is not included unless proxy pro is enabled
      refute_includes mapping_rule.keys, 'redirect_url'
    end

    def test_show_xml
      get :show, { id: @service.proxy.proxy_rules.first!, service_id: @service.id, format: :xml }
      assert_response :success

      mapping_rule = Hash.from_xml(@response.body).fetch('mapping_rule')
      assert mapping_rule
    end

    def test_create_json_without_proxy_pro
      Service.any_instance.expects(:using_proxy_pro?).returns(false).at_least_once

      assert_difference @proxy.proxy_rules.method(:count) do
        post :create, { service_id: @service.id, format: :json, mapping_rule: {
            http_method: 'POST', pattern: '/', delta: 1, metric_id: @service.metrics.first!.id, redirect_url: 'http://example.com/'
        } }
        assert_response :success
      end

      assert_equal nil, ProxyRule.last!.redirect_url
    end


    def test_create_json_with_proxy_pro
      Service.any_instance.expects(:using_proxy_pro?).returns(true).at_least_once

      assert_difference @proxy.proxy_rules.method(:count) do
        post :create, { service_id: @service.id, format: :json, mapping_rule: {
            http_method: 'POST', pattern: '/', delta: 1, metric_id: @service.metrics.first!.id, redirect_url: 'http://example.com/'
        } }
        assert_response :success
      end

      assert_equal 'http://example.com/', ProxyRule.last!.redirect_url
    end

    def test_update_json
      proxy_rule = @service.proxy.proxy_rules.first!

      patch :update, {
          id: proxy_rule, service_id: @service.id, format: :json,
          mapping_rule: {
            http_method: 'POST', pattern: '/foo', delta: 2
          }
      }

      assert_response :success

      proxy_rule.reload

      assert_equal 'POST', proxy_rule.http_method
      assert_equal '/foo', proxy_rule.pattern
      assert_equal 2, proxy_rule.delta
    end

    def test_update_json_with_proxy_pro
      proxy_rule = @service.proxy.proxy_rules.first!

      Service.any_instance.expects(:using_proxy_pro?).returns(true).at_least_once

      patch :update, {
          id: proxy_rule, service_id: @service.id, format: :json,
          mapping_rule: {
              redirect_url: redirect_url = 'http://example.com/foobar',
          }
      }
      assert_response :success

      response = JSON.parse(@response.body).fetch('mapping_rule')
      assert_equal redirect_url, response['redirect_url']

      proxy_rule.reload
      assert_equal redirect_url, proxy_rule.redirect_url
    end

    def test_destroy_json
      proxy_rule = @service.proxy.proxy_rules.first!

      assert_difference @proxy.proxy_rules.method(:count), -1 do
        delete :destroy, { id: proxy_rule, service_id: @service.id, format: :json }
        assert_response :success
      end

      assert_raise(ActiveRecord::RecordNotFound) { proxy_rule.reload }
    end
  end
end
