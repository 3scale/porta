# frozen_string_literal: true

class RemoveUserColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column(:users, :janrain_identifier) }
  end
end
