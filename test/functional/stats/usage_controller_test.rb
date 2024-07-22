require 'test_helper'


class Stats::UsageControllerTest < ActionController::TestCase
  def setup
    @provider = FactoryBot.create :provider_account
    @service = @provider.default_service
    host! @provider.external_domain
  end

  test 'index requires login' do
    get :index, params: { service_id: @service.id }
    assert_redirected_to '/login'
  end

  test 'index' do
    login_as(@provider.admins.first)
    Logic::RollingUpdates.stubs(skipped?: true)
    get :index, params: { service_id: @service.id }

    assert_response :success
    assert_template 'stats/usage/index'
    assert_equal @service.all_metrics, assigns(:metrics)
  end

  test 'top_applications' do
    metric = FactoryBot.create(:metric, :owner => @service,
                     :parent_id => @service.metrics.hits.id)
    login_as(@provider.admins.first)
    get :top_applications, params: { service_id: @service.id }
    assert_response :success
    assert assigns(:metrics)
    # assert assigns(:method_metrics)
  end

  test 'hours' do
    metric = FactoryBot.build_stubbed(:metric, :owner => @service)

    data = (0..23).inject(ActiveSupport::OrderedHash.new) do |memo, hour|
      memo["#{hour}:00"] = rand(1000)
      memo
    end

    Stats::Deprecated.expects(:average_usage_by_hours_for_all_metrics)
      .with(@service, :timezone => @provider.timezone)
      .returns(metric => data)

    login_as(@provider.admins.first)
    get :hours, params: { service_id: @service.id }

    assert_response :success
  end
end
