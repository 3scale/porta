class DropDeletedAt < ActiveRecord::Migration
  def up
    remove_column :accounts, :deleted_at
    remove_column :cinstances, :deleted_at
    remove_column :plans, :deleted_at
    remove_column :services, :deleted_at
    remove_column :users, :deleted_at
  end

  def down
    add_column :accounts, :deleted_at, :datetime
    add_column :cinstances, :deleted_at, :datetime
    add_column :plans, :deleted_at, :datetime
    add_column :services, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
  end
end
