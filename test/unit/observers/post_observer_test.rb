require 'test_helper'

class PostObserverTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def test_after_commit_on_create
    provider = FactoryBot.build_stubbed(:simple_provider)
    forum    = FactoryBot.build_stubbed(:forum, account: provider)

    Posts::PostCreatedEvent.expects(:create).at_least_once
    Account.any_instance.expects(:provider_can_use?).returns(true).at_least_once

    assert_no_difference Message.where(subject: 'New Forum Post').method(:count) do
      FactoryBot.create(:post, forum: forum)
    end

    Account.any_instance.expects(:provider_can_use?).returns(false).at_least_once

    # TODO
    # why 2?
    assert_difference Message.where(subject: 'New Forum Post').method(:count), +2 do
      FactoryBot.create(:post, forum: forum)
    end
  end
end
