class RenameIntentionsToDescriptionInCinstances < ActiveRecord::Migration
  def self.up
    rename_column :cinstances, :intentions, :description
  end

  def self.down
    rename_column :cinstances, :description, :intentions
  end
end
