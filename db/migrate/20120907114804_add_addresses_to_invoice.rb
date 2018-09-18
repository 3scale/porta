require 'migration/finance'

class AddAddressesToInvoice < ActiveRecord::Migration

  def self.up
    add_column :invoices, "fiscal_code", :string
    add_column :invoices, "vat_code", :string
    add_column :invoices, "vat_rate", :decimal, :precision => 20, :scale => 2
    add_column :invoices, "currency", :string, :limit => 4

    add_column :invoices, "from_address_name", :string
    add_column :invoices, "from_address_line1", :string
    add_column :invoices, "from_address_line2", :string
    add_column :invoices, "from_address_city", :string
    add_column :invoices, "from_address_region", :string
    add_column :invoices, "from_address_state", :string
    add_column :invoices, "from_address_country", :string
    add_column :invoices, "from_address_zip", :string
    add_column :invoices, "from_address_phone", :string

    add_column :invoices, "to_address_name", :string
    add_column :invoices, "to_address_line1", :string
    add_column :invoices, "to_address_line2", :string
    add_column :invoices, "to_address_city", :string
    add_column :invoices, "to_address_region", :string
    add_column :invoices, "to_address_state", :string
    add_column :invoices, "to_address_country", :string
    add_column :invoices, "to_address_zip", :string
    add_column :invoices, "to_address_phone", :string

    Migration::Finance.freeze_closed_invoices_raw
  end

  def self.down
    remove_column :invoices, "fiscal_code"
    remove_column :invoices, "vat_code"
    remove_column :invoices, "vat_rate"
    remove_column :invoices, "currency"

    remove_column :invoices, "from_address_name"
    remove_column :invoices, "from_address_line1"
    remove_column :invoices, "from_address_line2"
    remove_column :invoices, "from_address_city"
    remove_column :invoices, "from_address_state"
    remove_column :invoices, "from_address_region"
    remove_column :invoices, "from_address_country"
    remove_column :invoices, "from_address_zip"
    remove_column :invoices, "from_address_phone"

    remove_column :invoices, "to_address_name"
    remove_column :invoices, "to_address_line1"
    remove_column :invoices, "to_address_line2"
    remove_column :invoices, "to_address_city"
    remove_column :invoices, "to_address_state"
    remove_column :invoices, "to_address_region"
    remove_column :invoices, "to_address_country"
    remove_column :invoices, "to_address_zip"
    remove_column :invoices, "to_address_phone"
  end
end
