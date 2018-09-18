class NullPositionForActsAsList < ActiveRecord::Migration
  def up
    change_column :plans, "position", :integer, default: 0, null: true
  end

  def down
    change_column :plans, "position", :integer, default: 0, null: false
  end
end
