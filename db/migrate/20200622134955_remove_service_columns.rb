# frozen_string_literal: true

require "system/database/#{System::Database.adapter}"

class RemoveServiceColumns < ActiveRecord::Migration[5.0]
  def up
    columns = %w[act_as_product end_user_registration_required default_end_user_plan_id
      oneline_description txt_api txt_features infobar draft_name display_provider_keys
      credit_card_support_email admin_support_email tech_support_email
    ]

    sql_remove_columns = if System::Database.oracle?
      "ALTER TABLE services DROP (#{columns.join(', ')})"
    else
      columns.inject("ALTER TABLE services") { |sql, column| sql + "\nDROP COLUMN #{column}," }.chomp(',') + ';'
    end

    safety_assured { execute sql_remove_columns }
  end
end
