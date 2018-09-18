require 'test_helper'


class Stats::UsageControllerTest < ActionController::TestCase
  def setup
    @provider = Factory :provider_account
    @service = @provider.default_service
    @request.host = @provider.domain
  end

  test 'index requires login' do
    get :index, :service_id => @service.id
    assert_redirected_to '/login'
  end

  test 'index' do
    login_as(@provider.admins.first)
    Logic::RollingUpdates.stubs(skipped?: true)
    get :index, :service_id => @service.id

    assert_response :success
    assert_template 'stats/usage/index'
    assert_equal @service.metrics, assigns(:metrics)
  end

  test 'top_applications' do
    metric = Factory(:metric, :service => @service,
                     :parent_id => @service.metrics.hits.id)
    login_as(@provider.admins.first)
    get :top_applications, :service_id => @service.id
    assert_response :success
    assert assigns(:metrics)
    # assert assigns(:method_metrics)
  end

  test 'hours' do
    metric = Factory.stub(:metric, :service => @service)

    data = (0..23).inject(ActiveSupport::OrderedHash.new) do |memo, hour|
      memo["#{hour}:00"] = rand(1000)
      memo
    end

    Stats::Deprecated.expects(:average_usage_by_hours_for_all_metrics)
      .with(@service, :timezone => @provider.timezone)
      .returns(metric => data)

    login_as(@provider.admins.first)
    get :hours, :service_id => @service.id

    assert_response :success
  end
end
