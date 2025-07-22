# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::IterableJob

  def build_enumerator(*_args, cursor:)
    active_record_records_enumerator(AutoAccountDeletionQueries.should_be_suspended, cursor:)
  end

  def each_iteration(item, *_args)
    item.suspend
  end
end
