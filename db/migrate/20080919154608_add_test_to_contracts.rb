class AddTestToContracts < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.boolean :test, :null => false, :default => false
    end
  end

  def self.down
    change_table :contracts do |t|
      t.remove :test
    end
  end
end
