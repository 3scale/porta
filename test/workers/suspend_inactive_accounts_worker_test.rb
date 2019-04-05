# frozen_string_literal: true

require 'test_helper'

class SuspendInactiveAccountsWorkerTest < ActiveSupport::TestCase
  test 'suspends the accounts that should be automatically suspended' do
    tenant = FactoryBot.create(:simple_provider)

    AutoAccountDeletionQueries.expects(:should_be_suspended).returns(Account.where(id: tenant.id))

    SuspendInactiveAccountsWorker.new.perform

    assert tenant.reload.suspended?
  end
end
