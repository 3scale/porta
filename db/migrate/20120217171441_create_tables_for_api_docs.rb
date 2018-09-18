class CreateTablesForApiDocs < ActiveRecord::Migration
  def self.up
    create_table :api_docs_services do |t|
      t.integer :account_id
      t.integer :tenant_id, :limit => 8
      t.string :name
      t.string :host
      t.text :body
      t.text :description
      t.boolean :published, :default => false
      t.timestamps
    end

  end

  def self.down
    drop_table :api_docs_services
  end
end
