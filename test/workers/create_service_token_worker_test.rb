require 'test_helper'

class CreateServiceTokenWorkerTest < ActiveSupport::TestCase

  FakeEvent = Struct.new(:event_id, :service, :token_value)

  def test_enqueue
    CreateServiceTokenWorker.expects(:perform_async).once

    event = FakeEvent.new('12345')

    CreateServiceTokenWorker.enqueue(event)
  end

  def test_perform
    Sidekiq::Testing.inline! do
      token   = 'Alaska12345'
      service = FactoryBot.create(:simple_service, id: 999)
      service.service_tokens.delete_all
      event   = FakeEvent.new('1235', service, token)

      EventStore::Repository.expects(:find_event!).returns(event).twice
      ServiceTokenService.expects(:update_backend).with(instance_of(ServiceToken)).twice

      assert_difference ServiceToken.method(:count), +1 do
        CreateServiceTokenWorker.perform_async(event)
        # for one event there should be only one service token
        CreateServiceTokenWorker.perform_async(event)
      end
    end
  end
end
