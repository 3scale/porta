class RemoveViewstatusFromProfilesAndAccounts < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.remove :viewstatus
    end

    change_table :accounts do |t|
      t.remove :viewstatus
    end
  end

  def self.down
    change_table :profiles do |t|
      t.string :viewstatus, :default => 'PRIVATE'
    end

    change_table :accounts do |t|
      t.string :viewstatus, :default => 'PRIVATE'
    end
  end
end
