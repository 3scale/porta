class CreateDeletions < ActiveRecord::Migration
  def self.up
    create_table :deletions do |t|
      t.string :deletable_type
      t.integer :deletable_id
      t.datetime :scheduled_at
      t.text :reason
      t.datetime :messaged_users_at

      t.timestamps
    end
  end

  def self.down
    drop_table :deletions
  end
end
