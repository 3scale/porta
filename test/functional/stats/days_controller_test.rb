require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::DaysControllerTest < ActionController::TestCase

  # def setup
  #   FactoryBot.build_stubbed(:master_account)
  #   @request.host = MAIN_DOMAIN
  # end

  # test 'index requires login' do
  #   get :index
  #   assert_redirected_to login_url
  # end
  #
  # test 'show requires login' do
  #   get :show, :id => 'wednesday', :metric_id => '42'
  #   assert_redirected_to login_url
  # end

  # test 'index' do
  #   provider_account = stub_provider_account

  #   metric = FactoryBot.build_stubbed(:metric)
  #
  #   data = ActiveSupport::OrderedHash.new
  #   data['monday'] = 346
  #   data['tuesday'] = 987
  #   data['wednesday'] = 1045
  #   data['thursday'] = 1432
  #   data['friday'] = 1002
  #   data['saturday'] = 203
  #   data['sunday'] = 101

  #   Stats::Deprecated.expects(:average_usage_by_weekdays_for_all_metrics).
  #     with(provider_account.service).
  #     returns(metric => data)

  #   login_as(provider_account.admin)
  #   get :index
  #
  #   assert_response :success
  #   assert_template 'admin/stats/days/index'
  #   assert_active_menu(:stats)
  #   assert_equal provider_account.service, assigns(:service)
  # end

  # test 'show' do
  #   provider_account = stub_provider_account

  #   metric = FactoryBot.build_stubbed(:metric)
  #   stub_find(provider_account.service.metrics, metric)

  #   expect_data_for_show(provider_account.service, metric)
  #
  #   login_as(provider_account.admin)
  #   get :show, :id => 'tuesday', :metric_id => metric.to_param
  #
  #   assert_response :success
  #   assert_template 'admin/stats/days/show'
  # end
  #
  # test 'show via ajax' do
  #   provider_account = stub_provider_account

  #   metric = FactoryBot.build_stubbed(:metric)
  #   stub_find(provider_account.service.metrics, metric)

  #   expect_data_for_show(provider_account.service, metric)
  #
  #   login_as(provider_account.admin)
  #   xhr :get, :show, :id => 'tuesday', :metric_id => metric.to_param

  #   assert_response :success
  #   assert_template 'admin/stats/days/show'
  #   assert_nil @response.layout
  # end

  # private

  # def expect_data_for_show(service, metric)
  #   data = ActiveSupport::OrderedHash.new
  #   data[time(2009, 6, 2)] = returning(ActiveSupport::OrderedHash.new) do |day|
  #     day[time(2009, 6, 2, 00, 00)] = 4
  #     day[time(2009, 6, 2, 01, 00)] = 5
  #     # ...
  #   end

  #   data[time(2009, 6, 9)] = returning(ActiveSupport::OrderedHash.new) do |day|
  #     day[time(2009, 6, 9, 00, 00)] = 12
  #     day[time(2009, 6, 9, 01, 00)] = 18
  #     # ...
  #   end

  #   Stats::Deprecated.expects(:usage_in_day).
  #     with(service, :day => 'tuesday', :metric => metric).
  #     returns(data)
  #   data
  # end
end
