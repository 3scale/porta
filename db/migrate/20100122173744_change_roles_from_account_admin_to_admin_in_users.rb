class ChangeRolesFromAccountAdminToAdminInUsers < ActiveRecord::Migration
  def self.up
    execute('UPDATE users SET role = "admin" WHERE role = "account_admin"')
  end

  def self.down
    execute('UPDATE users SET role = "account_admin" WHERE role = "admin"')

    superadmin = Account.master.users.by_role(:account_admin).first
    superadmin.role = :admin
    superadmin.save!
  end
end
