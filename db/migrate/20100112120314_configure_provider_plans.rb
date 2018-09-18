class ConfigureProviderPlans < ActiveRecord::Migration
  def self.up
  end

  def self.down
    Account.transaction do
      Account.providers.each do |account|
        account.bought_cinstance.decustomize_plan!
      end
    end
  end

  private

  def self.enable_feature(accounts, name)
    feature = Account.master.service.features.find_by_system_name!(name)

    accounts.each do |account|
      unless account.bought_plan.features.include?(feature)
        plan = account.bought_cinstance.customize_plan!
        plan.features << feature
      end
    end
  end
end
