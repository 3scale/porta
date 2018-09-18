class RenameChangesToAuditedChanges < ActiveRecord::Migration
  def self.up
    add_column :audits, :audited_changes, :text
    execute "update audits set audited_changes=changes"
  end

  def self.down
  end
end
