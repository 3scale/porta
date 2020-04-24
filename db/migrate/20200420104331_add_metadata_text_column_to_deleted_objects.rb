# frozen_string_literal: true

class AddMetadataTextColumnToDeletedObjects < ActiveRecord::Migration[5.0]
  def change
    add_column :deleted_objects, :metadata, :text
  end
end
