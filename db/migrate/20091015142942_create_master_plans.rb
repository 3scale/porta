class CreateMasterPlans < ActiveRecord::Migration
  def self.up
  end

  def self.down
    Account.with_deleted.master.service.features.destroy_all
    Account.with_deleted.master.service.plans[1..-1].each(&:destroy)
    Account.with_deleted.master.service.plans.each { |plan| plan.usage_limits.destroy_all }
  end
end
