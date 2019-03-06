# frozen_string_literal: true

class CreateDeletedObjectEntries < ActiveRecord::Migration
  def change
    create_table :deleted_object_entries do |t|
      t.references :owner, polymorphic: true, index: true, type: :bigint
      t.references :object, polymorphic: true, index: true, type: :bigint
      t.datetime :created_at, null: false
    end
  end
end
