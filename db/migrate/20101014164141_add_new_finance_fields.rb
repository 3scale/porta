class AddNewFinanceFields < ActiveRecord::Migration
  def self.up
    add_column :invoices, :period, :date
    add_column :invoices, :issued_on, :date
    add_column :invoices, :state, :string, :null => false, :default => 'open'
    add_column :line_items, :started_at, :time
    change_column :line_items, :quantity, :integer, :null => true, :default => nil
  end

  def self.down
    remove_columns :invoices, :period, :issued_on, :state
    remove_columns :line_items, :started_at
    change_column :line_items, :quantity, :integer, :null => false, :default => 0
  end
end
