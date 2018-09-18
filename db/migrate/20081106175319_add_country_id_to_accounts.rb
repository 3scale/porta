class AddCountryIdToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.remove :currency
      t.belongs_to :country
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove_belongs_to :country
      t.string :currency, :default => 'EUR'
    end
  end
end
