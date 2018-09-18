class AddDeletedAtToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :deleted_at, :datetime
  end
end
