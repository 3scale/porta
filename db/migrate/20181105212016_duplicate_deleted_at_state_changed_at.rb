# frozen_string_literal: true

class DuplicateDeletedAtStateChangedAt < ActiveRecord::Migration
  def up
    Account.transaction do
      Account.scheduled_for_deletion.where.has{ deleted_at != nil }.find_each do |account|
        account.update_column(:state_changed_at, account.deleted_at) or raise ActiveRecord::Error
      end
    end
  end

  def down
    Account.update_all(state_changed_at: nil)
  end
end
