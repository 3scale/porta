class DropContractUserSpecificData < ActiveRecord::Migration
  def self.up
    remove_column :cinstances, :user_specific_data
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
