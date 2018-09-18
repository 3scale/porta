class AddAttachmentsPdfToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :pdf_file_name, :string
    add_column :invoices, :pdf_content_type, :string
    add_column :invoices, :pdf_file_size, :integer
    add_column :invoices, :pdf_updated_at, :datetime
  end

  def self.down
    remove_column :invoices, :pdf_file_name
    remove_column :invoices, :pdf_content_type
    remove_column :invoices, :pdf_file_size
    remove_column :invoices, :pdf_updated_at
  end
end
