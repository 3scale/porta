class DisallowNullValueInReports < ActiveRecord::Migration
  def self.up
    execute('UPDATE reports SET value = 0 WHERE value IS NULL')

    change_table :reports do |t|
      t.change(:value, :integer, :null => false, :default => 0)
    end
  end

  def self.down
    change_table :reports do |t|
      t.change(:value, :integer, :null => true, :default => nil)
    end
  end
end
