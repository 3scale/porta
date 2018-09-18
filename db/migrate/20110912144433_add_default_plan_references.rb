class AddDefaultPlanReferences < ActiveRecord::Migration
  def self.up
    add_column :accounts, :default_account_plan_id, :integer
    add_column :services, :default_application_plan_id, :integer
    add_column :services, :default_service_plan_id, :integer

    ApplicationPlan.not_custom.find_each do |plan|
      Service.update_all("default_service_plan_id = #{plan.id}", "id = #{plan.issuer_id}") if plan.issuer && plan.master
    end

    ServicePlan.not_custom.find_each do |plan|
      Service.update_all("default_service_plan_id = #{plan.id}", "id = #{plan.issuer_id}") if plan.issuer && plan.master
    end

    AccountPlan.not_custom.find_each do |plan|
      Account.update_all("default_account_plan_id = #{plan.id}", "id = #{plan.issuer_id}") if plan.issuer && plan.master
    end
  end

  def self.down
    remove_column :accounts, :default_account_plan_id
    remove_column :services, :default_application_plan_id
    remove_column :services, :default_service_plan_id
  end
end
