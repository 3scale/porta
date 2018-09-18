class AddEnforceSSOToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :enforce_sso, :boolean, null: false, default: false
  end
end
