class ChangeUsersToAccountAdmins < ActiveRecord::Migration
  def self.up
    execute('UPDATE users SET role = "account_admin" WHERE role IS NULL OR role = ""')
  end

  def self.down
    execute('UPDATE users SET role = NULL WHERE role = "account_admin"')
  end
end
