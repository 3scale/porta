FactoryBot.define do
  factory(:event, class: EventStore::Repository.adapter) do
    event_id { SecureRandom.uuid }
    event_type RailsEventStore::Event.name
    provider_id { Account.master? ? Account.master.id : FactoryBot.create(:simple_master).id }

    stream 'all'

    data do
      {  }
    end

    metadata do
      { timestamp: Time.now }
    end
  end

  factory(:limit_alert, :class => Alert) do
    association :account
    association :cinstance

    state :unread

    timestamp { Time.now }
    sequence(:alert_id) {|n| n }
    level { Alert::ALERT_LEVELS.select{|l| l < 100}.sample }
    utilization { rand + 1 }
  end

  factory(:limit_violation, :parent => :limit_alert) do
    level {|alert| Alert::ALERT_LEVELS.select{|l| l >= 100}.sample }
  end
end
