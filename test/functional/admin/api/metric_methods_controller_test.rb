require 'test_helper'

class Admin::Api::MetricMethodsControllerTest < ActionController::TestCase

  def setup
    provider = FactoryGirl.create(:provider_account)
    @service = FactoryGirl.create(:service, account: provider)
    @metric  = @service.metrics.first

    host! provider.admin_domain

    login_provider provider
  end

  def test_index
    get :index, service_id: @service.id, metric_id: @metric.id, format: :xml

    assert_response :success
  end

  def test_create
    post :create, service_id: @service.id, metric_id: @metric.id,
      metric: { system_name: 'alaska', friendly_name: 'alaska' }, format: :xml

    assert_response :success
  end

  def test_create_record_not_unique
    Admin::Api::MetricMethodsController.any_instance.stubs(:create).raises(
      ActiveRecord::RecordNotUnique, 'Mysql2::Error: Duplicate entry')

    post :create, service_id: @service.id, metric_id: @metric.id,
      metric: { system_name: 'alaska', friendly_name: 'alaska' }, format: :xml

    assert_response :conflict
  end
end
