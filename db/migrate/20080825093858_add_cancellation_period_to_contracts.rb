class AddCancellationPeriodToContracts < ActiveRecord::Migration
  def self.up
    change_table :contracts do |t|
      t.integer :cancellation_period, :null => false, :default => 0
    end
  end

  def self.down
    change_table :contracts do |t|
      t.remove :cancellation_period
    end
  end
end
