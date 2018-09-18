class AddApplicationKeyUpdatedOnToWebHooks < ActiveRecord::Migration
  def change
    add_column :web_hooks, :application_key_updated_on, :boolean, default: false
  end
end
