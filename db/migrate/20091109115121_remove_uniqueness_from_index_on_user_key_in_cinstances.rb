class RemoveUniquenessFromIndexOnUserKeyInCinstances < ActiveRecord::Migration
  def self.up
    remove_index :cinstances, :user_key
    add_index :cinstances, :user_key, :unique => false
  end

  def self.down
    # This is not reversible, but it does not matter.
  end
end
