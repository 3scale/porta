class AddPositionToContract < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.integer :position, :null => false, :default => 0
    end

    change_table :services do |t|
      t.remove :contract_ordering
    end
  end

  def self.down
    change_table :contracts do |t|
      t.remove :position
    end

    change_table :services do |t|
      t.string :contract_ordering
    end
  end
end
