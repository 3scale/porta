class AddTimezoneToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :timezone, :string
  end

  def self.down
    remove_column :accounts, :timezone
  end
end
