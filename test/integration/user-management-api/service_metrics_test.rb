# frozen_string_literal: true

require 'test_helper'

class Admin::Api::MetricsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service = FactoryBot.create(:service, :account => @provider)

    host! @provider.admin_domain
  end

  test 'index' do
    service = FactoryBot.create :service, :account => @provider
    FactoryBot.create :metric, :service => service

    get(admin_api_service_metrics_path(service), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)
    #TODO: use the assertion helper pattern of other tests
    assert xml.xpath('.//metrics/metric/service_id').all? { |t| t.text == service.id.to_s }
  end

  test 'show' do
    metric = FactoryBot.create :metric, :service => @service

    get(admin_api_service_metric_path(@service, metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    #TODO: maybe better move this to metric unit_test #to_xml
    assert xml.xpath('.//metric/service_id').children.first.text == @service.id.to_s

    #TODO: maybe better move this to metric unit_test #to_xml
    refute xml.xpath('.//metric/id').empty?
    refute xml.xpath('.//metric/name').empty?
    refute xml.xpath('.//metric/system_name').empty?
    refute xml.xpath('.//metric/friendly_name').empty?
    refute xml.xpath('.//metric/unit').empty?
  end

  test 'show with wrong id' do
    # a metric of another service
    metric = FactoryBot.create :metric, :service => FactoryBot.create(:service, :account => @provider)

    get(admin_api_service_metric_path(@service, metric), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end

  test 'create' do
    post(admin_api_service_metrics_path(@service), params: { :provider_key => @provider.api_key, :format => :xml, :system_name => 'example', :friendly_name => 'friendly example', :unit => 'Mb' })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    refute xml.xpath('.//metric/id').empty?

    metric = @service.metrics.reload.last

    assert_equal "example", metric.name
    assert_equal "friendly example", metric.friendly_name
    assert_equal "Mb", metric.unit
  end

  test 'create errors xml' do
    post(admin_api_service_metrics_path(@service), params: { :provider_key => @provider.api_key, :format => :xml, :unit => "pounds" })

    assert_response :unprocessable_entity

    assert_xml_error @response.body, "Friendly name can't be blank"
  end

  test 'update' do
    metric = @service.metrics.create!(:system_name => 'old_name', :friendly_name => "old friendly", :unit => 'Mb')

    put("/admin/api/services/#{@service.id}/metrics/#{metric.id}", params: { :provider_key => @provider.api_key, :format => :xml, :system_name => 'new_name', :friendly_name => "new friendly", :unit => 'bucks' })

    assert_response :success

    metric.reload

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_equal xml.xpath('.//metric/id').children.first.to_s, metric.id.to_s
    assert_equal "old_name", metric.system_name # cannot update system_name
    assert_equal "new friendly", metric.friendly_name
    assert_equal "bucks", metric.unit
  end

  test 'update with wrong id' do
    put("/admin/api/services/#{@service.id}/metrics/libanana", params: { :provider_key => @provider.api_key, :format => :xml, :system_name => "jk" })

    assert_response :not_found
  end

  test 'destroy' do
    metric = FactoryBot.create :metric, :service => @service

    delete("/admin/api/services/#{@service.id}/metrics/#{metric.id}", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    assert_empty_xml @response.body

    assert_raise ActiveRecord::RecordNotFound do
      metric.reload
    end
  end

  test 'destroy with wrong id' do
    delete("/admin/api/services/#{@service.id}/metrics/libanana", params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :not_found
  end
end
