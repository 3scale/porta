class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.integer :user_id, :limit => 8
      t.string :key
      t.string :ip
      t.string :user_agent

      t.timestamp :accessed_at
      t.timestamp :revoked_at
      t.timestamps
    end
  end
end
