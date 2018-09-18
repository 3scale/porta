require 'app/models/account'

class FirstPublishedAccountAndServicePlansGoDefault < ActiveRecord::Migration
  def self.up

    CONNECT_DOMAINS.clear
    ThinkingSphinx.deltas_enabled = false

    Account.module_eval do
      def service_preffix
        Configuration.configuration["service_preffix"]
      end
    end

    Account.providers.find_each do |p|
      say "Marking plans of #{p.org_name}"
      if !p.valid? && (p.errors[:domain].presence || p.errors[:subdomain].presence)
        p.domain = nil
        p.generate_domains
      end
      service_plan = p.services.first.service_plans.default_or_nil || p.services.first.service_plans.first
      account_plan = p.account_plans.default_or_nil  || p.account_plans.first
      p.services.first.service_plans.default!(service_plan)
      p.account_plans.default!(account_plan)
    end
  ensure
    Account.module_eval do
      undef :service_preffix
    end
  end

  def self.down
  end
end
