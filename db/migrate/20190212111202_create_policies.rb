class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :name, null: false
      t.string :version, null: false
      t.binary :schema, null: false, limit: 16.megabytes
      t.references :account, index: true, foreign_key: { on_delete: :cascade }, null: false, limit: 8
      t.integer  :tenant_id, limit: 8
      t.timestamps
    end
  end
end
