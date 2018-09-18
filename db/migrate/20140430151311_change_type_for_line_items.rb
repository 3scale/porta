class ChangeTypeForLineItems < ActiveRecord::Migration
  def up
    change_column :line_items, :type, :string, null: true
  end

  def down
    change_column :line_items, :type, :string, null: false
  end
end
