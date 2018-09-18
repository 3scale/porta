class AddOriginToMessages < ActiveRecord::Migration
  def self.up
    change_table :messages do |t|
      t.string :origin
    end
  end

  def self.down
    change_table :messages do |t|
      t.remove :origin
    end
  end
end
