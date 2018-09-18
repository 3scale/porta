require 'test_helper'

class BackendEventTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  test "find" do
    BackendEvent.create(id: 232)
    assert BackendEvent.find(232)
  end

  test "validates presence of id" do
    assert_raise ActiveRecord::RecordInvalid do
      BackendEvent.create!
    end
  end

  test "database raise for index" do
    BackendEvent.create(id: 123)

    backend_event = BackendEvent.new(id: 123)

    assert_raise ActiveRecord::RecordNotUnique do
      backend_event.save(validate: false)
    end
  end
end
