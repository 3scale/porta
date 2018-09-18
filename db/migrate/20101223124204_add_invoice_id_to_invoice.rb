class AddInvoiceIdToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :friendly_id, :string, :null => false, :default => 'fix'

    Invoice.reset_column_information
    Invoice.find_each do |invoice|
      invoice.send(:set_friendly_id, 0)
      invoice.save!
      puts "Invoice #{invoice.id} has friendly ID #{invoice.friendly_id}"
    end
  end

  def self.down
    remove_column :invoices, :friendly_id
  end
end
