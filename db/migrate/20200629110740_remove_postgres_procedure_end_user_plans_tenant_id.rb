# frozen_string_literal: true

require "system/database/#{System::Database.adapter}"

class RemovePostgresProcedureEndUserPlansTenantId < ActiveRecord::Migration[5.0]
  def up
    return unless System::Database.postgres?
    System::Database::Postgres::TriggerProcedure.new('tp_end_user_plans_tenant_id', nil).drop
  end
end
