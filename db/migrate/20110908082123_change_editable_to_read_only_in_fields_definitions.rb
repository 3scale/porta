class ChangeEditableToReadOnlyInFieldsDefinitions < ActiveRecord::Migration
  def self.up
    rename_column :fields_definitions,  :editable,  :read_only
  end

  def self.down
    rename_column :fields_definitions,  :read_only,  :editable
  end
end
