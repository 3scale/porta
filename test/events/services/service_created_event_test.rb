require 'test_helper'

class Services::ServiceCreatedEventTest < ActiveSupport::TestCase

  def test_create
    Services::ServiceCreatedEvent.expects(:generate_token_value).returns('12345')

    provider = FactoryGirl.build_stubbed(:simple_provider)
    service  = FactoryGirl.build_stubbed(:simple_service, account: provider)
    user     = FactoryGirl.build_stubbed(:simple_user)
    event    = Services::ServiceCreatedEvent.create(service, user)

    assert event
    assert_equal event.provider, provider
    assert_equal event.service, service
    assert_equal event.user, user
    assert_equal event.token_value, '12345'
  end

  def test_after_commit
    provider = FactoryGirl.build_stubbed(:simple_provider)
    service  = FactoryGirl.build_stubbed(:simple_service, account: provider)
    user     = FactoryGirl.build_stubbed(:simple_user)
    event    = Services::ServiceCreatedEvent.create(service, user)

    assert_difference CreateServiceTokenWorker.jobs.method(:size) do
      event.after_commit
    end
  end
end
