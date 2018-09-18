class AddTransactionIdToReports < ActiveRecord::Migration
  def self.up
    change_table :reports do |t|
      t.belongs_to :transaction
    end
  end

  def self.down
    change_table :reports do |t|
      t.remove_belongs_to :transaction
    end
  end
end
