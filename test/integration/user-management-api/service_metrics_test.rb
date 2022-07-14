# frozen_string_literal: true

require 'test_helper'

class Admin::Api::MetricsTest < ActionDispatch::IntegrationTest
  include TestHelpers::XmlAssertions

  setup do
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = FactoryBot.create(:service, account: @provider)

    host! @provider.admin_domain
  end

  test 'index' do
    FactoryBot.create(:metric, service: @service)

    get admin_api_service_metrics_path(@service, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :success

    xml = xml_document
    #TODO: use the assertion helper pattern of other tests
    assert(xml.xpath('.//metrics/metric/service_id').all? { |t| t.text == @service.id.to_s })
  end

  test 'show' do
    metric = FactoryBot.create(:metric, owner: @service)

    get admin_api_service_metric_path(@service, metric, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    #TODO: maybe better move this to metric unit_test #to_xml
    assert_equal xml.xpath('.//metric/service_id').children.first.text, @service.id.to_s

    #TODO: maybe better move this to metric unit_test #to_xml
    assert_not xml.xpath('.//metric/id').empty?
    assert_not xml.xpath('.//metric/name').empty?
    assert_not xml.xpath('.//metric/system_name').empty?
    assert_not xml.xpath('.//metric/friendly_name').empty?
    assert_not xml.xpath('.//metric/unit').empty?
  end

  test 'show with wrong id' do
    # a metric of another service
    metric = FactoryBot.create(:metric, service: FactoryBot.create(:service, account: @provider))

    get admin_api_service_metric_path(@service, metric, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :not_found
  end

  test 'create' do
    post admin_api_service_metrics_path(@service, format: :xml), params: { provider_key: @provider.api_key,
                                                                           system_name: 'example',
                                                                           friendly_name: 'friendly example',
                                                                           unit: 'Mb' }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_not xml.xpath('.//metric/id').empty?

    metric = @service.metrics.reload.last

    assert_equal "example", metric.name
    assert_equal "friendly example", metric.friendly_name
    assert_equal "Mb", metric.unit
  end

  test 'create errors xml' do
    post admin_api_service_metrics_path(@service, format: :xml), params: { provider_key: @provider.api_key, unit: "pounds" }

    assert_response :unprocessable_entity

    assert_xml_error @response.body, "Friendly name can't be blank"
  end

  test 'update' do
    metric = @service.metrics.create!(system_name: 'old_name', friendly_name: "old friendly", unit: 'Mb')

    put admin_api_service_metric_path(@service, metric, format: :xml), params: { provider_key: @provider.api_key,
                                                                                 system_name: 'new_name',
                                                                                 friendly_name: 'new friendly',
                                                                                 unit: 'bucks' }

    assert_response :success

    metric.reload

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_equal xml.xpath('.//metric/id').children.first.to_s, metric.id.to_s
    assert_equal "old_name", metric.system_name # cannot update system_name
    assert_equal "new friendly", metric.friendly_name
    assert_equal "bucks", metric.unit
  end

  test 'update with wrong id' do
    put admin_api_service_metric_path(@service, id: 'libanana', format: :xml), params: { provider_key: @provider.api_key, system_name: "jk" }

    assert_response :not_found
  end

  test 'destroy' do
    metric = FactoryBot.create(:metric, owner: @service)

    delete admin_api_service_metric_path(@service, id: metric.id, format: :xml), params: { provider_key: @provider.api_key }

    assert_response :success

    assert_empty_xml @response.body

    assert_raise ActiveRecord::RecordNotFound do
      metric.reload
    end
  end

  test 'destroy with wrong id' do
    delete admin_api_service_metric_path(@service, id: 'libanana', format: :xml), params: { provider_key: @provider.api_key }

    assert_response :not_found
  end

  class RepresentationTest < Admin::Api::MetricsTest
    def self.runnable_methods
      super & instance_methods(false).map(&:to_s)
    end

    setup do
      @metric_svc = FactoryBot.create(:metric, service: @service, owner: nil) # has service attribute set
      @metric_no_svc = FactoryBot.create(:metric, owner: @service) # does not have service attribute set
      @metric_no_svc.update_column(:service_id, nil)
      assert_not @metric_no_svc.reload.service
    end

    test 'json representer does not rely on service_id model attribute' do
      get admin_api_service_metric_path(@service, @metric_svc, format: :json), params: { provider_key: @provider.api_key }

      assert_response :success
      json_svc = JSON.parse(response.body)
      assert_equal @metric_svc.id, json_svc.dig('metric', 'id')
      assert_match %r{/services/#{@service.id}$}, json_svc.dig('metric', 'links', 0, 'href')

      get admin_api_service_metric_path(@service, @metric_no_svc, format: :json), params: { provider_key: @provider.api_key }

      assert_response :success
      json_no_svc = JSON.parse(response.body)
      assert_equal @metric_no_svc.id, json_no_svc.dig('metric', 'id')
      assert_match %r{/services/#{@service.id}$}, json_no_svc.dig('metric', 'links', 0, 'href')
    end

    test 'xml representation does not rely on service_id model attribute' do
      get admin_api_service_metric_path(@service, @metric_svc, format: :xml), params: { provider_key: @provider.api_key }

      assert_response :success
      assert_xpath '//metric/service_id', @service.id.to_s
      assert_xpath '//metric/id', @metric_svc.id.to_s

      get admin_api_service_metric_path(@service, @metric_no_svc, format: :xml), params: { provider_key: @provider.api_key }

      assert_response :success
      assert_xpath '//metric/service_id', @service.id.to_s
      assert_xpath '//metric/id', @metric_no_svc.id.to_s
    end
  end
end
