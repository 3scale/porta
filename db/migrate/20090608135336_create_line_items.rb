class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.belongs_to :invoice
      t.string :name
      t.string :description
      t.decimal :cost, :precision => 20, :scale => 4
      t.string :currency, :null => false, :default => 'EUR', :limit => 4
      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
