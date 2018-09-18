class CreateLiquidPages < ActiveRecord::Migration
  def self.up
    create_table :liquid_pages do |t|
      t.integer :account_id
      t.string :title
      t.text :content
      t.integer :version

      t.timestamps
    end
  end

  def self.down
    drop_table :liquid_pages
  end
end
