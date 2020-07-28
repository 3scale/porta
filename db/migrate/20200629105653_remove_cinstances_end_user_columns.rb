# frozen_string_literal: true

class RemoveCinstancesEndUserColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column :cinstances, :end_user_required }
  end
end
