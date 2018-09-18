class AddParentIdToFieldsDefinitions < ActiveRecord::Migration
  def self.up
    add_column :fields_definitions, :target, :string
    add_column :fields_definitions, :hidden, :boolean
    add_column :fields_definitions, :required, :boolean
    add_column :fields_definitions, :label, :string
    add_column :fields_definitions, :name, :string
    add_column :fields_definitions, :choices, :string
    add_column :fields_definitions, :hint, :text
    add_column :fields_definitions, :editable, :boolean
    add_column :fields_definitions, :pos, :integer
    rename_column :fields_definitions, :provider_id, :account_id
    remove_column :fields_definitions, :fields

  end

  def self.down
    rename_column :fields_definitions, :account_id, :provider_id
    remove_column :fields_definitions, :pos
    remove_column :fields_definitions, :editable
    remove_column :fields_definitions, :hint
    remove_column :fields_definitions, :choices
    remove_column :fields_definitions, :name
    remove_column :fields_definitions, :label
    remove_column :fields_definitions, :required
    remove_column :fields_definitions, :hidden
    remove_column :fields_definitions, :target
    add_column :fields_definitions, :fields,  :text
  end
end
