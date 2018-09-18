class AddCreationTypeToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :creation_type, :string, default: 'manual'

    # 166142 invoices in production database
    Invoice.find_each do |invoice|
      invoice.update_column :creation_type, :background
    end
  end
end
