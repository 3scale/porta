# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::IterableJob

  def build_enumerator(cursor:)
    active_record_records_enumerator(AutoAccountDeletionQueries.should_be_suspended, cursor:)
  end

  def each_iteration(account)
    account.suspend
  end
end
