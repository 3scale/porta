class RemoveTestAttributeFromPlans < ActiveRecord::Migration
  def self.up
    Plan.connection.execute "DELETE FROM plans WHERE test = true"
    change_table Plan.table_name do |t|
      t.remove :test
    end
  end

  def self.down
    change_table Plan.table_name do |t|
      t.boolean :test, :default => false, :null => false
    end
  end
end
