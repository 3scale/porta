# frozen_string_literal: true

require 'test_helper'

module Tasks
  class Segment::SegmentTest < ActiveSupport::TestCase
    def given_segment_users_config(user_id_saved_locally)
      FakeFS do
        config = Rails.root.join('config', 'segment_users.csv')
        FakeFS::FileSystem.clone(config.dirname, '/tmp/config')
        config.open('w') { |f| f.puts(segment_users_csv(user_id_saved_locally)) }
        yield
      end
    end

    test 'save_deleted_users' do
      user_id = FactoryBot.create(:member).id
      given_segment_users_config(user_id) do
        execute_rake_task 'segment/segment.rake', 'segment:save_deleted_users', 'config/segment_users.csv'
      end
      deleted_object_ids = DeletedObject.users.pluck(:object_id)
      assert_includes deleted_object_ids, 1
      assert_includes deleted_object_ids, 2
      assert_not_includes deleted_object_ids, user_id
    end

    def segment_users_csv(user_id_saved)
      <<-CSV
      First name,Last name,Name,User ID,account_id
      ExampleName1,ExampleSurname1,Display Name 1,1,-11
      ExampleName2,ExampleSurname2,Display Name 2,2,
      ExampleName3,ExampleSurname3,Display Name 3,#{user_id_saved},
      CSV
    end
  end
end
