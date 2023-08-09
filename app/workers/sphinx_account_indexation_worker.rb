# frozen_string_literal: true

require_relative 'sphinx_indexation_worker'

# SphinxAccountIndexationWorker updates sphinx index for the Account model.
# It is enqueued when:
# - Account gets created, updated or deleted
# - User gets created, updated, deleted
# - Cinstance gets created, updated, deleted
class SphinxAccountIndexationWorker < SphinxIndexationWorker
  def perform(_model, id)
    account = Account.searchable.find_by(id: id)

    if account
      reindex(account)
    else
      buyers = Account.buyers.where(provider_account_id: id).pluck(:id)
      delete_from_index(Account, id, *buyers)
    end
  end
end
