class DeleteDraftServices < ActiveRecord::Migration
  def self.up
    disable_referential_integrity do
      delete('DELETE FROM services WHERE parent_id IS NOT NULL')
    end
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
