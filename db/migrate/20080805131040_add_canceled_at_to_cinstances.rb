class AddCanceledAtToCinstances < ActiveRecord::Migration
  def self.up
    change_table :cinstances do |t|
      t.datetime :canceled_at
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.remove :canceled_at
    end
  end
end
