class CreateFormFields < ActiveRecord::Migration
  def self.up
    create_table :form_fields do |table|
      table.belongs_to :account
      table.text :fieldsets
    end

    add_index :form_fields, :account_id
  end

  def self.down
    remove_index :form_fields, :column => :account_id
    drop_table :form_fields
  end
end
