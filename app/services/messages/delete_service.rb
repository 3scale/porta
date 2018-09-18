class Messages::DeleteService

  def self.run!(account:, association_class:, ids: [], delete_all: false)
    messages = association_class.of_account(account)
    messages = messages.where(id: ids) unless delete_all == true

    messages.update_all(hidden_at: DateTime.now)
  end
end
