# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServiceMetricMethodsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'

    @service = FactoryBot.create(:service, :account => @provider)
    @metric  = @service.metrics.hits
    @metric_method = FactoryBot.create(:metric,
                             :service => @service, :parent_id => @metric.id)


    host! @provider.admin_domain
  end

  test 'service not found' do
    get(admin_api_service_metric_methods_path(:service_id => 0, :metric_id => @metric.id), params: { :provider_key => @provider.api_key, :format => :xml })
    assert_response :not_found
  end

  test 'service api metric not found' do
    get(admin_api_service_metric_methods_path(:service_id => @service.id, :metric_id => 0), params: { :provider_key => @provider.api_key, :format => :xml })
    assert_response :not_found
  end

  test 'service api metrics index' do
    other_service = FactoryBot.create :service, :account => @provider
    other_metric  = other_service.metrics.hits
    FactoryBot.create(:metric, :service => other_service, :parent_id => other_metric.id)

    get(admin_api_service_metric_methods_path(@service, @metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    assert_metric_methods(@response.body, {:service_id => @service.id, :metric_id => @metric.id})
  end

  test 'service api metrics show' do
    get(admin_api_service_metric_method_path(@service, @metric, @metric_method), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    assert_metric_method(@response.body,
                         {:service_id => @service.id, :metric_id  => @metric.id,
                          :id => @metric_method.id})
  end

  test 'service api metrics show not found' do
    get(admin_api_service_metric_method_path(@service, @metric, :id => 0), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'service api metric create' do
    post(admin_api_service_metric_methods_path(@service, @metric), params: { :provider_key => @provider.api_key, :format => :xml, :system_name => 'example', :friendly_name => 'friendly example' })

    assert_response :success

    assert_metric_method(@response.body,
         {:service_id => @service.id, :metric_id => @metric.id, :system_name => "example", :friendly_name => "friendly example"})

    metric_method = @metric.children.last

    assert_equal "example", metric_method.name
    assert_equal "friendly example", metric_method.friendly_name
  end

  test 'service api metric create errors xml' do
    post(admin_api_service_metric_methods_path(@service, @metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :unprocessable_entity

    assert_xml_error @response.body, "Friendly name can't be blank"
  end

  test 'service api metric update' do
    metric_method = @metric.children.create!(:system_name => 'old_name',
        :friendly_name => "old friendly")

    put("/admin/api/services/#{@service.id}/metrics/#{@metric.id}/methods/#{metric_method.id}", params: { :provider_key => @provider.api_key, :format => :xml, :system_name => 'new_name', :friendly_name => "new friendly" })

    assert_response :success

    assert_metric_method(@response.body,
                         {:service_id => @service.id, :metric_id => @metric.id,
                          :system_name => "old_name", :friendly_name => "new friendly"}) # cannot update system_name

    metric_method.reload
    assert_equal "old_name", metric_method.system_name # cannot update system_name
    assert_equal "new friendly", metric_method.friendly_name
  end

  test 'service api metric update with wrong id' do
    put("/admin/api/services/#{@service.id}/metrics/#{@metric.id}/methods/0", params: { :provider_key => @provider.api_key })

    assert_response :not_found
  end

  test 'service api metric update errors xml' do
    put("/admin/api/services/#{@service.id}/metrics/#{@metric.id}/methods/#{@metric_method.id}", params: { :provider_key => @provider.api_key, :format => :xml, :friendly_name => "" })

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Friendly name can't be blank"
  end

  test 'service api metric destroy' do
    delete("/admin/api/services/#{@service.id}/metrics/#{@metric.id}/methods/#{@metric_method.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :success

    assert_empty_xml @response.body

    assert_raise ActiveRecord::RecordNotFound do
      @metric_method.reload
    end
  end

  test 'service api metric destroy with wrong id' do
    delete("/admin/api/services/#{@service.id}/metrics/#{@metric.id}/methods/0",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :not_found
  end

end
