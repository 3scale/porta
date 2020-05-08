# frozen_string_literal: true

require 'test_helper'

class ApplicationKeyBackendServiceTest < ActiveSupport::TestCase
  def setup
    @application = FactoryBot.create(:simple_cinstance, application_id: 'backend-app-id')
    @service = application.service
  end

  attr_reader :application, :service

  test 'delete_all' do
    app_keys = FactoryBot.build_stubbed_list(:application_key, 2, application: application)
    app_keys.each { |app_key| DeletedObject.create(owner: application, object: app_key, metadata: {value: app_key.value}) }

    app_key_of_another_application = FactoryBot.build_stubbed(:application_key)
    DeletedObject.create(object: app_key_of_another_application, owner: app_key_of_another_application.application)

    seq = sequence('app keys destroy sequence')
    app_keys.each { |app_key| ThreeScale::Core::ApplicationKey.expects(:delete).with(service.backend_id, application.application_id, app_key.value).in_sequence(seq) }

    ApplicationKeyBackendService.delete_all(application_id: application.id, service_backend_id: application.service.backend_id, application_backend_id: application.application_id)
  end

  test 'delete' do
    app_key = FactoryBot.build_stubbed(:application_key, application: application)
    DeletedObject.create(owner: application, object: app_key, metadata: {value: app_key.value})

    app_key_of_another_application = FactoryBot.build_stubbed(:application_key)
    DeletedObject.create(object: app_key_of_another_application, owner: app_key_of_another_application.application)

    ThreeScale::Core::ApplicationKey.expects(:delete).with(service.backend_id, application.application_id, app_key.value)

    ApplicationKeyBackendService.delete(service_backend_id: application.service.backend_id, application_backend_id: application.application_id, value: app_key.value)
  end
end
