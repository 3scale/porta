class AddCreateOriginToCinstances < ActiveRecord::Migration
  def self.up
    change_table :cinstances do |t|
      t.string :create_origin
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.remove :create_origin
    end
  end
end
