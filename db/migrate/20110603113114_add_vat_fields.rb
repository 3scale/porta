class AddVatFields < ActiveRecord::Migration
  def self.up
    add_column :accounts, :vat_code, :string
    add_column :accounts, :fiscal_code, :string
    add_column :accounts, :vat_rate, :decimal, :precision => 20, :scale => 2
  end

  def self.down
    remove_columns :accounts, :vat_code, :fiscal_code, :vat_rate
  end
end
