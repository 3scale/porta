class CreateProxyConfigs < ActiveRecord::Migration
  def change
    create_table :proxy_configs do |t|
      t.references :proxy, index: true, foreign_key: { on_delete: :cascade }, type: :bigint, null: false
      t.references :user, index: true, foreign_key: { on_delete: :nullify }, type: :bigint, null: true
      t.integer :version, null: false, default: 0
      t.bigint :tenant_id
      t.string :environment, null: false
      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
