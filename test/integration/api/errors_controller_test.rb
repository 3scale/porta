# frozen_string_literal: true

require 'test_helper'

class Api::ErrorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    provider = FactoryBot.create(:provider_account)
    @service = provider.default_service
    @service_errors = [{timestamp: Time.now.iso8601, message: 'fake error 1'}, {timestamp: 1.day.ago.to_time.iso8601, message: 'fake error 2'}]
    stub_backend_service_errors(@service, @service_errors)

    login! provider
  end

  test 'index with pagination' do
    get admin_service_errors_path(@service), params: { per_page: 1, page: 2 }
    assigned_errors = assigns(:errors)
    assert_equal 2, assigned_errors.size
    assigned_errors.each { |error| assert_instance_of(ThreeScale::Core::ServiceError, error) }
    assert_same_elements @service_errors, assigned_errors.map { |error| {timestamp: error.timestamp.to_time.iso8601, message: error.message} }
    assert_template 'api/errors/index'
  end

  test 'purge with js' do
    IntegrationErrorsService.any_instance.expects(:delete_all).with(@service.id)
    delete purge_admin_service_errors_path(@service, format: :js)
    assert_response :success
    assert_template 'api/errors/purge'
  end
end
