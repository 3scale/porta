class AddServicePlansHiddenToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :service_plans_ui_visible, :boolean, default: false
  end
end
