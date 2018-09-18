class AddMoreFieldsToLineItems < ActiveRecord::Migration
  def self.up
    change_table :line_items do |table|
      table.remove :currency
      table.string :type, :null => false, :default => ''
      table.belongs_to :cinstance
      table.belongs_to :metric
      table.timestamp :finished_at
      table.integer :quantity, :null => false, :default => 0

      table.change :cost, :decimal, :precision => 20, :scale => 4, :null => false, :default => 0
    end
  end

  def self.down
    change_table :line_items do |table|
      table.change :cost, :decimal, :precision => 20, :scale => 4, :null => true, :default => nil

      table.remove :quantity
      table.remove :finished_at
      table.remove_belongs_to :metric
      table.remove_belongs_to :cinstance
      table.remove :type
      table.string :currency, :limit => 4, :null => false, :default => 'EUR'
    end
  end
end
