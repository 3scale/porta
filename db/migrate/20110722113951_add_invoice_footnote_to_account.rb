class AddInvoiceFootnoteToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :invoice_footnote, :text
  end

  def self.down
    remove_column :accounts, :invoice_footnote
  end
end
