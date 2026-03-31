# frozen_string_literal: true

FactoryBot.define do
  factory(:alert) do
    association :cinstance
    account { cinstance.user_account }
    sequence(:alert_id) { |n| "alert-#{n}" }
    level { 50 }
    utilization { 0.5 }
    timestamp { Time.now }
  end
end
