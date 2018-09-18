class CreateAccountAndServicePlans < ActiveRecord::Migration
  def self.up
    # FIXME: otherwise this whole thing won't run
    require 'account'
    require 'contract'
    require 'cinstance'

    Cinstance.reset_column_information

    Account.module_eval do
      def service_preffix
        Configuration.configuration["service_preffix"]
      end
    end

    add_plans_to_provider(Account.master)
    Account.providers.find_each { |p| add_plans_to_provider(p) }
    Account.find_each { |buyer| buy_plans(buyer) }
    # Contract.find_each do |c|
    #   type = Plan.find(c.plan_id) rescue next
    #   c.update_attribute(:plan_type, type.class.to_s)
    # end
  ensure
    Account.module_eval do
      undef :service_preffix
    end
  end

  def self.down
  end

  private

  def self.buy_plans(buyer)
    if buyer
      puts "#{buyer.org_name}"
      provider = buyer.provider_account

      if provider && !provider.master?
        plan = provider.account_plans.detect{|p| p.master}
        buyer.buy!(plan)
        puts "- bought account plan #{plan.name}"

        plan = provider.services.first.service_plans.detect{|p| p.master}
        buyer.buy!(plan)
        puts "- bought service plan #{plan.name}"
      end
    end
  end

  def self.add_plans_to_provider(provider)
    if provider
      puts "Creating plans for provider #{provider.org_name}"
      account_plan = provider.account_plans.create!( :name => 'Default', :issuer => provider, :master => true)

      if provider.services.empty?
        provider.send(:create_default_service)
      end

      service_plan = provider.services.first.service_plans.create!( :name => 'Default', :issuer => provider.services.first, :master => true)
    end
  end
end
