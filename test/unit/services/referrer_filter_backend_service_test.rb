# frozen_string_literal: true

require 'test_helper'

class ReferrerFilterBackendServiceTest < ActiveSupport::TestCase
  def setup
    @application = FactoryBot.create(:simple_cinstance, application_id: 'backend-app-id')
    @service = application.service
  end

  attr_reader :application, :service

  test 'delete_all' do
    ref_filters = FactoryBot.build_stubbed_list(:referrer_filter, 2, application: application)
    ref_filters.each { |ref_filter| DeletedObject.create(owner: application, object: ref_filter, metadata: {value: ref_filter.value}) }

    ref_fil_of_another_application = FactoryBot.build_stubbed(:referrer_filter)
    DeletedObject.create(object: ref_fil_of_another_application, owner: ref_fil_of_another_application.application)

    seq = sequence('ref filters destroy sequence')
    ref_filters.each { |ref_filter| ThreeScale::Core::ApplicationReferrerFilter.expects(:delete).with(service.backend_id, application.application_id, ref_filter.value).in_sequence(seq) }

    ReferrerFilterBackendService.delete_all(application_id: application.id, service_backend_id: service.backend_id, application_backend_id: application.application_id)
  end

  test 'delete' do
    ref_filter = FactoryBot.build_stubbed(:referrer_filter, application: application)
    DeletedObject.create(owner: application, object: ref_filter, metadata: {value: ref_filter.value})

    ref_filter_of_another_application = FactoryBot.build_stubbed(:referrer_filter)
    DeletedObject.create(object: ref_filter_of_another_application, owner: ref_filter_of_another_application.application)

    ThreeScale::Core::ApplicationReferrerFilter.expects(:delete).with(service.backend_id, application.application_id, ref_filter.value)

    ReferrerFilterBackendService.delete(service_backend_id: service.backend_id, application_backend_id: application.application_id, value: ref_filter.value)
  end
end
