# frozen_string_literal: true

require_relative 'sphinx_indexation_worker'

# SphinxAccountIndexationWorker updates sphinx index for the Account model.
# It is enqueued when:
# - Account gets created and updated (deletion is handled only when scheduled for deletion)
# - User gets created, updated, deleted
# - Cinstance gets created, updated, deleted
# fixme: destroy doesn't remove indexes due to disabled callbacks in config/initializers/sphinx.rb
class SphinxAccountIndexationWorker < SphinxIndexationWorker
  def perform(account)
    if account.will_be_deleted?
      to_delete = account.buyers.pluck(:id) << account.id
      # This is how deletion is performed by ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks#delete_from_sphinx
      # If callbacks were enabled, we could delete individual records one by one with:
      # ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks.after_destroy(instance)
      indices(account).each do |index|
        ThinkingSphinx::Deletion.perform index, to_delete
      end
    else
      super
    end
  end
end
