class BillingModeToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :billing_strategy, :string

    Account.reset_column_information
    Settings.reset_column_information

    Account.find_each(:include => :settings, :conditions => 'settings.billing_mode IS NOT NULL') do |account|
      putc '.'
      old = account.settings.billing_mode

      if old
        puts "Updating #{account.inspect}"
        account.create_billing_strategy(:prepaid => (old == 'prepaid'),
                                        :charging_enabled  => (old != 'informational'))
      else
        puts "Skipping #{account.inspect}"
      end
    end
  end

  def self.down
    remove_column :accounts, :billing_strategy
  end
end
