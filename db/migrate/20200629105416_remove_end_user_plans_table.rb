# frozen_string_literal: true

class RemoveEndUserPlansTable < ActiveRecord::Migration[5.0]
  def up
    drop_table :end_user_plans
  end
end
