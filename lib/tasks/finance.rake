# frozen_string_literal: true

require 'progress_counter'

desc "Manual checks for finance operations"
namespace :finance do
  desc "Print buyers' traffic and cost (requires month in form of date [2012-08-01])"
  task :estimate_variable, [:month] => [:environment] do |task, args|
    if args[:month]
      month = Month.new(Date.parse(args[:month]))
      puts "Calculating estimates for #{month}..."

      Account.providers.each do |provider|
        puts "Provider #{provider.name} -----------------"

        provider.provided_cinstances.find_each do |app|
          cost = app.calculate_variable_cost(month).last.values.inject(0) { |sum,n| n+sum }
          hits = app.plan.metrics.find_by_name 'hits'
          data = Stats::Client.new(c)

          if cost > 0
            traffic = data.total(:period   => month, :timezone => provider.timezone, :metric   => hits)
            puts [ provider.id, provider.name, app.account.id, app.account.name, traffic, cost.to_f ].join(',')
          end
        end
      end
    else
      puts '[month] param has to be supplied'
    end
  end

  namespace :payment_intents do
    desc 'Copies all data from payment_intents.payment_intent_id to new column reference'
    task backfill_reference: :environment do
      progress = ProgressCounter.new(PaymentIntent.count)
      PaymentIntent.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |payment_intent|
          payment_intent.update!(reference: payment_intent.attributes['payment_intent_id'])
        end
        progress.call(increment: batch.size)
      end
    end
  end
end
