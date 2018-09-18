class RemoveModuleSwitches < ActiveRecord::Migration
  def self.up
    remove_column :settings, :liquid_allowed
    remove_column :settings, :credit_card_detail_allowed
  end

  def self.down
  end
end
