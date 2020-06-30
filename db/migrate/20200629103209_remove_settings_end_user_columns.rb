# frozen_string_literal: true

require "system/database/#{System::Database.adapter}"

class RemoveSettingsEndUserColumns < ActiveRecord::Migration[5.0]
  def up
    sql_remove_columns = if System::Database.oracle?
      <<~SQL.strip
      ALTER TABLE settings
        DROP (end_users_switch, end_user_plans_ui_visible)
      SQL
    else
      <<~SQL.strip
      ALTER TABLE settings
        DROP COLUMN end_users_switch,
        DROP COLUMN end_user_plans_ui_visible;
      SQL
    end
    safety_assured { execute sql_remove_columns }
  end
end
