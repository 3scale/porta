class RemoveCinstanceIdToLineItems < ActiveRecord::Migration
  def up
    remove_column :line_items, :cinstance_id
  end

  def down
    add_column :line_items, :cinstance_id, :integer
  end
end
