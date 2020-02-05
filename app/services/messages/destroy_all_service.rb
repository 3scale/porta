# frozen_string_literal: true

class Messages::DestroyAllService
  def self.run!(account:, association_class:, scope:)
    association_class
      .of_account(account)
      .public_send(scope)
      .update_all(deleted_at: DateTime.now)

    # hard destroy as background job
    DestroyAllDeletedObjectsWorker.perform_later(association_class.to_s)
  end
end
