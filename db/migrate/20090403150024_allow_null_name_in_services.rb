class AllowNullNameInServices < ActiveRecord::Migration
  def self.up
    change_column :services, :name, :string, :null => true
    change_column :services, :draft_name, :string, :null => true
  end

  def self.down
    change_column :services, :name, :string, :null => false
    change_column :services, :draft_name, :string, :null => false
  end
end
