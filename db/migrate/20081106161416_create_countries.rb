class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :code
      t.string :name
      t.string :currency
      t.decimal :tax_rate, :precision => 5, :scale => 2, :null => false,
        :default => 0.0
      t.timestamps
    end

    add_index :countries, :code
  end

  def self.down
    drop_table :countries
  end
end
