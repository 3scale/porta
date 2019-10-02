# frozen_string_literal: true

require 'test_helper'

class ApiIntegration::SettingsResultTest < ActiveSupport::TestCase
  test 'raises ServiceMismatchError in initialize when then parameter service is different than the proxy service' do
    assert_raise ApiIntegration::SettingsResult::ServiceMismatchError do
      ApiIntegration::SettingsResult.new(proxy: proxy, service: FactoryBot.create(:simple_service))
    end
  end

  test '#valid? returns true if both are valid' do
    assert service.valid?
    assert proxy.valid?
    assert settings_result.valid?
  end

  test '#valid? returns false if the service is invalid' do
    service.name = ''
    refute service.valid?
    refute settings_result.valid?
  end

  test '#valid? returns false if the proxy is invalid' do
    proxy.error_status_no_match = ''
    refute proxy.valid?
    refute settings_result.valid?
  end

  test '#update! updates both when they are valid' do
    assert settings_result.update!(attributes)
    service_attributes.each { |field_name, value| assert_equal value, service.public_send(field_name) }
    proxy_attributes.each   { |field_name, value| assert_equal value, proxy.public_send(field_name)   }
  end

  test '#update! raises ActiveRecord::RecordInvalid and does not save any change when the proxy attributes are invalid' do
    old_service_attributes = service.attributes.slice(service_attributes.keys)
    old_proxy_attributes   = proxy.attributes.slice(proxy_attributes.keys)

    proxy_attributes[:error_headers_auth_failed] = ''
    assert_raises(ActiveRecord::RecordInvalid) { settings_result.update!(attributes) }
    old_service_attributes.each { |field_name, value| assert_equal value, service.public_send(field_name) }
    old_proxy_attributes.each   { |field_name, value| assert_equal value, proxy.public_send(field_name)   }
  end

  test '#update! raises ActiveRecord::RecordInvalid and does not save any change when the service attributes are invalid' do
    old_service_attributes = service.attributes.slice(service_attributes.keys)
    old_proxy_attributes   = proxy.attributes.slice(proxy_attributes.keys)

    service_attributes[:name] = ''
    assert_raises(ActiveRecord::RecordInvalid) { settings_result.update!(attributes) }
    old_service_attributes.each { |field_name, value| assert_equal value, service.public_send(field_name) }
    old_proxy_attributes.each   { |field_name, value| assert_equal value, proxy.public_send(field_name)   }
  end

  test '#update updates both when they are valid' do
    assert settings_result.update(attributes)
    service_attributes.each { |field_name, value| assert_equal value, service.public_send(field_name) }
    proxy_attributes.each   { |field_name, value| assert_equal value, proxy.public_send(field_name)   }
  end

  test '#update returns false and does not save when the proxy attributes are invalid and #errors returns the errors' do
    old_service_attributes = service.attributes.slice(service_attributes.keys)
    old_proxy_attributes   = proxy.attributes.slice(proxy_attributes.keys)

    proxy_attributes[:error_headers_auth_failed] = ''
    refute settings_result.update(attributes)
    old_service_attributes.each { |field_name, value| assert_equal value, service.public_send(field_name) }
    old_proxy_attributes.each   { |field_name, value| assert_equal value, proxy.public_send(field_name)   }

    assert_equal 'Error headers auth failed invalid', settings_result.errors[:proxy].to_sentence
    assert_empty settings_result.errors[:service]
  end

  test '#update returns false and does not save when the service attributes are invalid and #errors returns the errors' do
    old_service_attributes = service.attributes.slice(service_attributes.keys)
    old_proxy_attributes   = proxy.attributes.slice(proxy_attributes.keys)

    service_attributes[:name] = ''
    refute settings_result.update(attributes)
    old_service_attributes.each { |field_name, value| assert_equal value, service.public_send(field_name) }
    old_proxy_attributes.each   { |field_name, value| assert_equal value, proxy.public_send(field_name)   }

    assert_equal 'Name can\'t be blank', settings_result.errors[:service].to_sentence
    assert_empty settings_result.errors[:proxy]
  end

  test '#update and #update! for deployment_option "hosted"' do
    service.update!(deployment_option: 'self_managed') unless service.deployment_option == 'self_managed'
    proxy.update!(endpoint: 'http://prod.example.com:80', staging_endpoint: 'http://staging.example.com:80')

    service_attributes[:deployment_option] = 'hosted'
    assert settings_result.update(attributes)
    assert_equal 'hosted', service.deployment_option
    assert_equal "http://#{service.system_name}-#{service.account_id}.apicast.dev:8080", proxy.endpoint
    assert_equal "http://#{service.system_name}-#{service.account_id}.staging.apicast.dev:8080", proxy.staging_endpoint
  end

  private

  def proxy
    @proxy ||= FactoryBot.create(:simple_proxy, service: service)
  end

  def service
    @service ||= FactoryBot.create(:simple_service, deployment_option: 'self_managed')
  end

  def settings_result
    @settings_result ||= ApiIntegration::SettingsResult.new(service: service, proxy: proxy)
  end

  def service_attributes
    @service_attributes ||= {name: 'new name'}
  end

  def proxy_attributes
    @proxy_attributes ||= {endpoint: 'http://myapi.example.com:8123'}
  end

  def attributes
    {service_attributes: service_attributes, proxy_attributes: proxy_attributes}
  end
end
