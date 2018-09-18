class CleanupAudits < ActiveRecord::Migration
  def up
    remove_column :audits, :changes
  end

  def down
    add_column :audits, :changes, :text
  end
end
