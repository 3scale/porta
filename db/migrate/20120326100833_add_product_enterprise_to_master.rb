class AddProductEnterpriseToMaster < ActiveRecord::Migration
  def self.up
    m = Account.master
    m_s = m.settings
    m_s.product = 'enterprise'
    m.self_domain = m.domain
    m_s.save(false)
    m.save!
  end

  def self.down
  end
end
