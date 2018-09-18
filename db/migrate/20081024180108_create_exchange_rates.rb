class CreateExchangeRates < ActiveRecord::Migration
  def self.up
    create_table :exchange_rates, :force => true do |t|
      t.string :source_currency
      t.string :target_currency
      t.float :rate
      t.timestamps
    end
    
    add_index :exchange_rates, [:source_currency, :target_currency, :created_at], :name => :exchange_rates_index
  end

  def self.down
    drop_table :exchange_rates
  end
end
