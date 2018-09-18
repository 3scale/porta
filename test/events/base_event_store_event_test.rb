require 'test_helper'

class BaseEventStoreEventTest < ActiveSupport::TestCase

  class DummieEvent < BaseEventStoreEvent

    class << self

      def create(provider, name, number)
        new(
          name:   name,
          number: number,
          metadata: {
            provider_id: provider.id
          }
        )
      end

      def valid?(_provider, name, _number)
        name.present?
      end
    end
  end

  class NoCreateMethodEvent < BaseEventStoreEvent
  end

  def test_create_and_publish
    DummieEvent.expects(:create).once

    DummieEvent.create_and_publish!(provider, 'Alex', 1)

    DummieEvent.expects(:create).never

    DummieEvent.create_and_publish!(provider, nil, 1)
  end

  def test_create
    assert_raise NotImplementedError do
      NoCreateMethodEvent.create_and_publish!('Alex')
    end
  end

  private

  def provider
    @_provider ||= FactoryGirl.build_stubbed(:simple_provider, id: 1)
  end
end
