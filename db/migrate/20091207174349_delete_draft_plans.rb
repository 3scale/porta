class DeleteDraftPlans < ActiveRecord::Migration
  def self.up
    delete('DELETE FROM plans WHERE parent_id IS NOT NULL')
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
