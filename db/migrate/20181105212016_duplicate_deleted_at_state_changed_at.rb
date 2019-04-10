# frozen_string_literal: true

class DuplicateDeletedAtStateChangedAt < ActiveRecord::Migration
  def up
    # Done in a query instead of Ruby because later on deleted_at is removed programatically and otherwise it says it doesn't exist
    query = <<~SQL
      UPDATE accounts
      SET state_changed_at = deleted_at
      WHERE state = 'scheduled_for_deletion' AND (deleted_at IS NOT NULL);
    SQL
  end

  def down
    Account.update_all(state_changed_at: nil)
  end
end
