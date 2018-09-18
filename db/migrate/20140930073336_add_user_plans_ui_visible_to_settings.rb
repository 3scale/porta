class AddUserPlansUiVisibleToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :end_user_plans_ui_visible, :boolean, default: false
  end
end
