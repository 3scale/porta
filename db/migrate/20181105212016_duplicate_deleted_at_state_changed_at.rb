# frozen_string_literal: true

class DuplicateDeletedAtStateChangedAt < ActiveRecord::Migration
  def up
    Account.scheduled_for_deletion.where.not(deleted_at: nil).update_all('state_changed_at = deleted_at')
  end

  def down
    Account.update_all(state_changed_at: nil)
  end
end
