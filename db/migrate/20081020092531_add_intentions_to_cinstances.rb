class AddIntentionsToCinstances < ActiveRecord::Migration
  def self.up
    change_table :cinstances do |t|
      t.text :intentions
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.remove :intentions
    end
  end
end
