# frozen_string_literal: true

class RemoveAccessTokenColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column(:access_tokens, :owner_type) }
  end
end
