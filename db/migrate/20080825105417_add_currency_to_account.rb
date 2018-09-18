class AddCurrencyToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.string :currency
    end

    change_table :contracts do |t|
      t.remove :currency
    end
  end

  def self.down
    change_table :contracts do |t|
      t.string :currency, :default => 'EUR'
    end

    change_table :accounts do |t|
      t.remove :currency
    end
  end
end
