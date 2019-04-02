# frozen_string_literal: true

require 'test_helper'

class StaleAccountWorkerTest < ActiveSupport::TestCase
  test 'schedules for deletion the accounts that should be automatically scheduled for deletion' do
    tenant = FactoryBot.create(:simple_provider)

    Account.expects(:should_be_automatically_scheduled_for_deletion).returns(Account.where(id: tenant.id))

    StaleAccountWorker.new.perform

    assert tenant.reload.scheduled_for_deletion?
  end
end
