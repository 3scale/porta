class DefaultNilFieldsEndUserRemoval < ActiveRecord::Migration[5.0]
  def change
    change_column_null :settings, :end_users_switch, true
    change_column_null :settings, :end_user_plans_ui_visible, true

    change_column_null :cinstances, :end_user_required, true

    change_column_null :plans, :end_user_required, true

    change_column_null :services, :end_user_registration_required, true
    change_column_null :services, :default_end_user_plan_id, true
  end
end
