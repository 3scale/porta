# frozen_string_literal: true

require 'test_helper'

class BackendDeleteEndUsersWorkerTest < ActiveSupport::TestCase
  test 'perform' do
    service_id = FactoryBot.create(:simple_service).id

    ThreeScale::Core::User.expects(:delete_all_for_service).with(service_id)

    Sidekiq::Testing.inline! { BackendDeleteEndUsersWorker.perform_async(service_id) }
  end
end
