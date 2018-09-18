class AddLostPasswordTokenGeneratedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lost_password_token_generated_at, :datetime
  end
end
