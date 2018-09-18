class AddProperValuesToMasterSwitches < ActiveRecord::Migration
  def self.up
    m_s = Account.master.settings
    m_s.multiple_applications_switch = "hidden"
    m_s.multiple_users_switch = "hidden"
    m_s.finance_switch = "hidden"
    m_s.service_plans_switch = "hidden"
    m_s.save(false)

    # doing it manually as we're bypassing the state machine
    m_s.account.create_billing_strategy unless m_s.account.billing_strategy
  end

  def self.down
  end
end
