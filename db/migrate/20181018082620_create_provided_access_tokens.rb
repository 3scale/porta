class CreateProvidedAccessTokens < ActiveRecord::Migration
  def change
    create_table :provided_access_tokens do |t|
      t.text :value
      t.belongs_to :user, limit: 8, foreign_key: true
      t.belongs_to :account, limit: 8, foreign_key: true
      t.integer :tenant_id, limit: 8
      t.datetime :expires_at
      t.timestamps
    end
  end
end
