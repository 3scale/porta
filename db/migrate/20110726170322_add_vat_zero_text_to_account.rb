class AddVatZeroTextToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :vat_zero_text, :text
  end

  def self.down
    remove_column :accounts, :vat_zero_text
  end
end
