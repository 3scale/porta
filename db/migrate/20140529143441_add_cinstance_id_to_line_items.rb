class AddCinstanceIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :cinstance_id, :integer
  end
end
