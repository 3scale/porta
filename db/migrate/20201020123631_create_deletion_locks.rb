# frozen_string_literal: true

class CreateDeletionLocks < ActiveRecord::Migration[5.0]
  def change
    create_table :deletion_locks do |table|
      table.string   :lock_key,   null: false, unique: true
      table.datetime :created_at, null: false
    end
  end
end
