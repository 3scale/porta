class ChangePaymentColumnsInSettings < ActiveRecord::Migration
  def self.up
    execute('UPDATE settings SET billing_allowed = 1 WHERE payments_allowed')

    change_table :settings do |table|
      table.remove :payments_allowed
      table.remove :billing_enabled
      table.rename :payments_enabled, :billing_enabled
      table.change :billing_enabled, :boolean, :null => false, :default => false
      table.change :billing_allowed, :boolean, :null => false, :default => false
      table.rename :payment_type, :billing_mode
    end

    execute('UPDATE settings SET billing_enabled = 1, billing_mode = "informational"
             WHERE billing_mode = "postpaid"')
  end

  def self.down
    change_table :settings do |table|
      table.rename :billing_mode, :payment_type
      table.rename :billing_enabled, :payments_enabled
      table.boolean :billing_enabled
      table.boolean :payments_allowed
    end

    execute('UPDATE settings SET billing_enabled = 1, payments_enabled = 0, billing_allowed = 1,
             payments_allowed = 1, payment_type = "postpaid"
             WHERE payment_type = "informational"')
    execute('UPDATE settings SET billing_enabled = 1 WHERE payments_enabled')
    execute('UPDATE settings SET payments_allowed = 1 WHERE payments_enabled')
    execute('UPDATE settings SET billing_allowed = 1 WHERE billing_enabled')
    execute('UPDATE settings SET payment_type = "prepaid" WHERE payment_type <> "postpaid"')
  end
end
