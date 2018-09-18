class AddAccountPlansHiddenToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :account_plans_ui_visible, :boolean, default: false
  end
end
