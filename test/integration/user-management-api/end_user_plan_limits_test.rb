require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::EndUserPlanLimitsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory :provider_account, :domain => 'provider.example.com'
    @service  = @provider.first_service!
    @plan     = Factory :end_user_plan, :service => @service
    @metric   = Factory :metric, :service => @service
    @limit    = Factory :usage_limit, :plan => @plan, :metric => @metric

    @provider.settings.allow_end_users!

    host! @provider.admin_domain
  end

  test 'without switch' do
    @provider.settings.deny_end_users!

    get(admin_api_end_user_plan_metric_limits_path(@plan, @metric),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :forbidden
  end


  test 'end_user_plan not found' do
    get(admin_api_end_user_plan_metric_limits_path(:end_user_plan_id => 0,
                                                    :metric_id => @metric.id),
                                                    :provider_key => @provider.api_key, :format => :xml)

    assert_response :not_found
  end

  test 'end user plan metric not found' do
    get(admin_api_end_user_plan_metric_limits_path(:end_user_plan_id => @plan.id,
                                                    :metric_id => 0),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :not_found
  end

  test 'end_user_plan_metric_limits_index' do
    get(admin_api_end_user_plan_metric_limits_path(@plan, @metric),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    assert_usage_limits(@response.body, {
                          :plan_id => @plan.id,
                          :metric_id => @metric.id })
  end

  test 'end_user_plan_metric_limit_show' do
    get(admin_api_end_user_plan_metric_limit_path(@plan, @metric, @limit),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    assert_usage_limit(@response.body, {
                         :id => @limit.id,
                         :plan_id => @plan.id,
                         :metric_id => @metric.id })
  end

  test 'end_user_plan_plan_metric show not found' do
    get(admin_api_end_user_plan_metric_limit_path(:end_user_plan_id => @plan.id,
                                                          :metric_id => @metric.id,
                                                          :id => 0),
             :provider_key => @provider.api_key, :format => :xml)

    assert_response :not_found
  end

  test 'end_user_plan_metric create' do
    post(admin_api_end_user_plan_metric_limits_path(@plan, @metric),
              :provider_key => @provider.api_key, :format => :xml,
              :period => 'week', :value => 15)

    assert_response :success

    assert_usage_limit(@response.body, {
                         :plan_id => @plan.id, :metric_id => @metric.id,
                         :period => 'week', :value => 15
                       })

    assert_xml '/limit/id' do |xml|
      id = xml.text
      limit = @plan.usage_limits.find(id)

      assert_equal limit, @metric.usage_limits.find(id)
      assert_equal :week, limit.period
      assert_equal 15, limit.value
      assert_equal @plan, limit.plan
    end
  end

  test 'end_user_plan_metric create errors' do
    post admin_api_end_user_plan_metric_limits_path(@plan, @metric, format: :xml),
         :provider_key => @provider.api_key, :period => 'a-while'

    assert_response :unprocessable_entity

    assert_xml_error @response.body, "Period is invalid"
  end

  test 'end_user_plan_metric_limits update' do
    assert @limit.period != "month"
    assert @limit.value  != 20

    put admin_api_end_user_plan_metric_limit_path(@plan, @metric, @limit, format: :xml),
                                                  :period => 'month', :value => "20",
                                                  :provider_key => @provider.api_key
    assert_response :success
    assert_usage_limit(@response.body,
                       { :plan_id => @plan.id,
                         :metric_id => @metric.id,
                         :period => "month", :value => "20" })

    @limit.reload
    #TODO: dry this assertions all over the tests
    assert_equal :month, @limit.period
    assert_equal 20, @limit.value
  end

  test 'end_user_plan_metrics_limit update not found' do
    put admin_api_end_user_plan_metric_limit_path(@plan, @metric, id: 0, format: :xml),
                                                  :provider_key => @provider.api_key

    assert_response :not_found
  end

  test 'end_user_plan_metrics_limit update errors' do
    put admin_api_end_user_plan_metric_limit_path(@plan, @metric, @limit, format: :xml),
                                                  :period => 'century',
                                                  :provider_key => @provider.api_key

    assert_response :unprocessable_entity

    assert_xml_error @response.body, "Period is invalid"
  end

  test 'end_user_plan_metrics_limit destroy' do
    delete admin_api_end_user_plan_metric_limit_path(@plan, @metric, @limit,
                                                     :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    refute @response.body.presence

    assert_raise ActiveRecord::RecordNotFound do
      @limit.reload
    end
  end

  test 'end_user_plan_metrics_limit destroy not found' do
    delete admin_api_end_user_plan_metric_limit_path(@plan, @metric, :id => 0,
                                                     :provider_key => @provider.api_key, :format => :xml)

    assert_response :not_found
  end

end
