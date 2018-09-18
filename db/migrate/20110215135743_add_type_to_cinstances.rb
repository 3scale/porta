class AddTypeToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :type, :string, :null => false, :default => 'Cinstance'
  end

  def self.down
    remove_column :cinstances, :type
  end
end
