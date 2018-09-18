require 'test_helper'

class Api::MetricsControllerTest < ActionController::TestCase
  def setup
    provider  = FactoryGirl.create(:provider_account)
    @service   = FactoryGirl.create(:service, account: provider)
    @metric   = FactoryGirl.create(:metric, service: @service, friendly_name: 'super metric')

    request.host = provider.admin_domain
    login_as(provider.admins.first)
  end

  def test_index
    get :index, service_id: @service.id
    assert_response :success
    assert_select 'title', "Metrics - Index | Red Hat 3scale API Management"
    assert_select '#metrics a', 'Hits'
  end

  def test_new_metric
    get :new, service_id: @service.id
    assert_response :success
    assert_select 'title', "Metrics - New | Red Hat 3scale API Management"
  end

  def test_new_method #child of hits
    get :new, service_id: @service.id,
      metric_id: @service.metrics.hits
    assert_response :success
    assert_select 'title', "Metrics - New | Red Hat 3scale API Management"
  end

  def test_create_metric
    assert_difference @service.metrics.method(:count) do
      post :create, service_id: @service.id, metric: { system_name: 'upgrades', friendly_name: 'upgrades', unit: 'upgrades' }
      assert_response :redirect
    end
  end

  def test_create_a_method #child of hits
    assert_difference @service.metrics.method(:count) do
      post :create, service_id: @service.id, metric_id: @service.metrics.hits, metric: { system_name: 'alaska', friendly_name: 'alaska' }
      assert_response :redirect
    end
  end

  def test_edit
    get :edit, service_id: @service.id, id: @metric.id
    assert_response :success
    assert_select 'title', "Metrics - Edit | Red Hat 3scale API Management"
  end

  def test_destroy
    assert_difference @service.metrics.method(:count), -1 do
      delete :destroy, service_id: @service.id, id: @metric.id
      assert_response :redirect
      assert_equal 'The metric was deleted', flash[:notice]
    end
  end

  def test_destroy_hits_metric
    assert_no_difference @service.metrics.method(:count) do
      delete :destroy, service_id: @service.id, id: @service.metrics.hits
      assert_response :redirect
      assert_equal 'The Hits metric cannot be deleted', flash[:error]
    end
  end
end
