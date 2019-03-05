class AddIdentifierToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :identifier, :string # not adding null: false here so we can migrate in two steps
    add_index :policies, [:account_id, :identifier], unique: true
  end
end
