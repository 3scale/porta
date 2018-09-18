class AddServiceEndUserRegistrationRequired < ActiveRecord::Migration
  def self.up
    add_column :services, :end_user_registration_required, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :services, :end_user_registration_required
  end
end
