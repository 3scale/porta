class MoveSuperadminOverToMasterAccount < ActiveRecord::Migration
  def self.up
    if select_value('SELECT COUNT(id) FROM users WHERE role = "admin"').to_i > 1
      raise "Multiple superadmins found"
    end

    master_id  = select_value('SELECT id FROM accounts WHERE master')
    superadmin = select_one('SELECT id, account_id FROM users WHERE role = "admin"')

    if superadmin
      execute(%(UPDATE users SET account_id = #{master_id} WHERE id = #{superadmin['id']}))

      if superadmin['account_id'].to_i != master_id.to_i
        execute(%(DELETE FROM accounts WHERE id = #{superadmin['account_id']}))
        execute(%(DELETE FROM profiles WHERE account_id = #{superadmin['account_id']}))
        execute(%(DELETE FROM services WHERE account_id = #{superadmin['account_id']}))
      end
    end
  end

  def self.down
    # Not necessary. Superadmin can work as well from the master account.
  end
end
