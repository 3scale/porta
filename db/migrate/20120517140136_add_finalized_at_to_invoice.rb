class AddFinalizedAtToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :finalized_at, :datetime
  end

  def self.down
    remove_column :invoices, :finalized_at
  end
end
