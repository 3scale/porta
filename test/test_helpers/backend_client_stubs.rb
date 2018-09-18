module TestHelpers
  module BackendClientStubs

    # this is the new preferred way of stubbing the backend

    def self.included(base)
      base.teardown(:clear_backend_stubs)
    end

    def stub_backend_service_errors(service, raw_errors = [])
      errors = raw_errors.map { |error| ThreeScale::Core::ServiceError.new(error) }
      ThreeScale::Core::ServiceError.stubs(:load_all).with(service.id, any_parameters).returns(
        ThreeScale::Core::APIClient::Collection.new(errors, errors.size)
      )
    end

    def expect_backend_delete_all_service_errors(service)
      ThreeScale::Core::ServiceError.expects(:delete_all).with(service.id).returns(true)
    end

    def stub_backend_referrer_filters(*referrers)
      ThreeScale::Core::ApplicationReferrerFilter.stubs(:load_all).returns(referrers.flatten)
    end

    def expect_backend_create_referrer_filter(application, referrer = 'foo.example.com')
      ThreeScale::Core::ApplicationReferrerFilter.expects(:save)
        .with(application.service.backend_id,
             application.application_id,
             referrer).returns(referrer)
    end

    def expect_backend_delete_referrer_filter(application, referrer)
      ThreeScale::Core::ApplicationReferrerFilter.expects(:delete)
        .with(application.service.backend_id,
             application.application_id,
             referrer).returns(referrer)
    end

    def stub_backend_change_provider_key
      ThreeScale::Core::Service.stubs(:change_provider_key!).returns(true)
    end

    def stub_backend_get_keys(*keys)
      ThreeScale::Core::ApplicationKey.stubs(:load_all).returns(keys.flatten)
    end

    def expect_backend_create_key(application, key = "key-key")
      ThreeScale::Core::ApplicationKey.expects(:save).with(application.service.backend_id,
                                                           application.application_id,
                                                           key)
    end

    def expect_backend_delete_key(application, key)
      ThreeScale::Core::ApplicationKey.expects(:delete).with(application.service.backend_id,
                                                             application.application_id,
                                                             key)
    end

    def stub_backend_utilization(data = [])
      collection = BackendClient::Application::Utilization::Collection.new(data)
      ::BackendClient::Application.any_instance.stubs(:utilization).returns(collection)
    end

    # unstubs

    def unstub_backend_utilization
      ::BackendClient::Application.any_instance.unstub(:utilization)
    end

    def unstub_backend_get_keys
      ::BackendClient::Application.any_instance.unstub(:keys)
    end

    def unstub_backend_referrer_filters
      ::BackendClient::Application.any_instance.unstub(:referrers)
    end

    # make sure you put this method in the teardown in the tests when you stub the backend
    # e.g. check test/functional/applications/referrer_filters_controller_test
    def clear_backend_stubs
      unstub_backend_get_keys
      unstub_backend_utilization
      unstub_backend_referrer_filters

      ::BackendClient::Application.any_instance.unstub(:create_referrer_filter, :create_key)
    end

  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::BackendClientStubs)
