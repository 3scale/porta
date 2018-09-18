class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens  do |t|
      t.belongs_to :owner, polymorphic: { null: false }, null: false, limit: 8
      t.text   :scopes
      t.string :value, null: false
      t.string :name, null: false
      t.string :permission, null: false
    end

    add_index :access_tokens, [:owner_id, :owner_type], name: 'idx_auth_tokens_of_user'
    add_index :access_tokens, [:value, :owner_id, :owner_type], name: 'idx_value_auth_tokens_of_user', unique: true
  end
end
