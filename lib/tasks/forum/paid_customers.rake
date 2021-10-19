# frozen_string_literal: true

namespace :forum do
  desc 'exports active customers in forum_of_paid_customers'
  task :paid_customers => :environment  do

    master_service = Account.master.services.first
    paid_plans = Plan.left_outer_joins(:pricing_rules).where('setup_fee > 0 OR cost_per_month > 0 OR cost_per_unit > 0'); nil
    master_paid_plans = paid_plans.where(issuer: master_service); nil

    contracts = Contract.where(plan: master_paid_plans); nil

    headers = [
      'Account ID', 'Contact Email', 'Account Name',
      'Plan', 'Number of posts last 6 months', 'Date of most recent post'
    ]

    CSV.open('paid_customers.csv', 'w+', write_headers: true, headers: headers) do |csv|
      contracts.find_each do |contract|
        provider = contract.buyer_account
        first_admin = provider.first_admin!

        next unless provider
        forum = provider.forum # can be nil

        posts_count = forum&.posts&.where('created_at > ?', 6.months.ago)&.count
        last_post = forum&.posts&.latest_first&.first
        csv << [
          provider.id, first_admin.email, provider.org_name,
          contract.plan.name, posts_count.to_i,
          last_post&.created_at || 'N/A'
        ]
      end
    end
  end
end
