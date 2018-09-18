class AddDueOnToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :due_on, :date
  end

  def self.down
    remove_column :invoices, :due_on
  end
end
