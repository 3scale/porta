# frozen_string_literal: true

class CreateDeletedObjects < ActiveRecord::Migration
  def change
    create_table :deleted_objects do |t|
      t.references :owner, polymorphic: true, index: true, type: :bigint
      t.references :object, polymorphic: true, index: true, type: :bigint
      t.datetime :created_at, null: false
    end
  end
end
