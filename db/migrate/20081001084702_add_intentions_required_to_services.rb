class AddIntentionsRequiredToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :intentions_required, :boolean, :default => false
  end

  def self.down
    remove_column :services, :intentions_required
  end
end
