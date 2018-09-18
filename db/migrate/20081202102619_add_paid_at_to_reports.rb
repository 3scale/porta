class AddPaidAtToReports < ActiveRecord::Migration
  def self.up
    change_table :reports do |t|
      t.datetime :paid_at
    end
  end

  def self.down
    change_table :reports do |t|
      t.remove :paid_at
    end
  end
end
