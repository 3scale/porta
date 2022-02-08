# frozen_string_literal: true

require_relative 'sphinx_indexation_worker'

# SphinxAccountIndexationWorker updates sphinx index for the Account model.
# It is enqueued when:
# - Account gets created, updated or deleted
# - User gets created, updated, deleted
# - Cinstance gets created, updated, deleted
class SphinxAccountIndexationWorker < SphinxIndexationWorker
  def perform(model, id)
    pk = model.primary_key
    account = model.find_by(pk => id)

    indices_for_model(model).each do |index|
      if account && index.scope.find_by(pk => id)
        reindex(index, account)
      elsif account && !account.master?
        delete_from_index(index, id, *account.buyers.pluck(:id))
      else
        delete_from_index(index, id)
      end
    end
  end
end
