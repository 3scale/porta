# frozen_string_literal: true

class RemoveEndUserPlans < ActiveRecord::Migration[5.0]
  def change
    safety_assured { remove_column :settings, :end_users_switch }
    safety_assured { remove_column :settings, :end_user_plans_ui_visible }

    safety_assured { remove_column :cinstances, :end_user_required }

    safety_assured { remove_column :plans, :end_user_required }

    safety_assured { remove_column :services, :end_user_registration_required }
    safety_assured { remove_column :services, :default_end_user_plan_id }

    drop_table :end_user_plans
  end
end
