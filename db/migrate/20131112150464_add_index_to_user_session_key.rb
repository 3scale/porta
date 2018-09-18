class AddIndexToUserSessionKey < ActiveRecord::Migration

  def self.up
    add_index :user_sessions, :key,     :name => 'idx_key'
    add_index :user_sessions, :user_id, :name => 'idx_user_id'
  end

  def self.down
    remove_index :user_sessions, :name => 'idx_key'
    remove_index :user_sessions, :name => 'idx_user_id'
  end
end
