# frozen_string_literal: true

class RemovePlansEndUserColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column :plans, :end_user_required }
  end
end
