# frozen_string_literal: true

require 'test_helper'

class SuspendInactiveAccountsWorkerTest < ActiveSupport::TestCase
  test 'suspends the accounts that should be automatically suspended' do
    tenant = FactoryBot.create(:simple_provider)

    AutoAccountDeletionQueries.expects(:should_be_suspended).returns(Account.where(id: tenant.id))

    SuspendInactiveAccountsWorker.new.perform

    assert tenant.reload.suspended?
  end

  test "doesn't suspend accounts not in the scope" do
    tenant1 = FactoryBot.create(:simple_provider)
    tenant2 = FactoryBot.create(:simple_provider)

    AutoAccountDeletionQueries.expects(:should_be_suspended).returns(Account.where(id: tenant1.id))

    SuspendInactiveAccountsWorker.new.perform

    assert_not tenant2.reload.suspended?
  end

  test 'ignores accounts that fail to validate' do
    valid_tenant = FactoryBot.create(:simple_provider)
    # a blank, but not an empty value, because an empty string causes
    # OCIError: ORA-01400: cannot insert NULL into ("RAILS"."ACCOUNTS"."ORG_NAME")
    invalid_tenant = FactoryBot.build(:simple_provider, org_name: ' ')
    invalid_tenant.save!(validate: false)

    AutoAccountDeletionQueries.expects(:should_be_suspended).returns(Account.where(id: [valid_tenant.id, invalid_tenant.id]))

    SuspendInactiveAccountsWorker.new.perform

    assert valid_tenant.reload.suspended?
    assert_not invalid_tenant.reload.suspended?
  end
end
