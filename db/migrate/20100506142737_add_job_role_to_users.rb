class AddJobRoleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :job_role, :string
  end

  def self.down
    remove_column :users, :job_role
  end
end
