class AdditionalTogglesForSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :credit_card_detail_allowed,  :boolean, :default => false
    add_column :settings, :setup_fee_allowed,  :boolean, :default => false        
  end

  def self.down
    remove_column :settings, :credit_card_detail_allowed
    remove_column :settings, :setup_fee_allowed
  end
end
