# frozen_string_literal: true

class FindAndDeleteScheduledAccountsWorker
  include Sidekiq::Worker

  def perform
    Account.deleted_since.find_each(&DeleteAccountHierarchyWorker.method(:perform_later))
  end
end
