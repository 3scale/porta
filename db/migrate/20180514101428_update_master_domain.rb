class UpdateMasterDomain < ActiveRecord::Migration
  def up
    master = Account.master
    master.update_attribute(:domain, master.self_domain)
  end
end
