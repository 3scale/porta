# frozen_string_literal: true

# Run it with rails runner, for example:
# $ bundle exec rails runner suspend_inactive.rb

require 'progress_counter'

module SuspendInactiveProviders

  module_function

  PLANS = [
    2357355454121, # 2013 Enterprise (Trial)
    2357355852196, # 90 Day Trial (50K calls/day)
    2357355916595, # Enterprise (Eval)
    2357355814696, # Developer
    2357355852194, # Personal (5K calls/day)
  ]

  def scope
    Account.providers
           .includes(:bought_cinstances)
           .where(state: 'approved')
           .where(bought_cinstances: { first_daily_traffic_at: ..6.months.ago })
           .where(bought_cinstances: { plan_id: PLANS })
  end

  def call
    total = scope.count
    puts "Providers count: #{total}"

    providers = scope.find_each

    each_with_progress_counter(providers, total) do |provider|
      provider.suspend
    end
  end

  def each_with_progress_counter(enumerable, count)
    progress = ProgressCounter.new(count)
    enumerable.each do |element|
      progress.call
      yield element
    end
  end
end

SuspendInactiveProviders.call
