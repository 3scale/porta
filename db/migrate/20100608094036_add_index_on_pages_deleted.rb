class AddIndexOnPagesDeleted < ActiveRecord::Migration

  def self.up
    add_index :pages, 'deleted', :name => 'idx_deleted'
  end

  def self.down
    remove_index :pages, :name => 'idx_deleted'
  end
end
