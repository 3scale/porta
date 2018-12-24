Factory.define(:event, class: EventStore::Repository.adapter) do |event|
  event.event_id { SecureRandom.uuid }
  event.event_type RailsEventStore::Event.name
  event.provider_id { Account.master? ? Account.master.id : FactoryBot.create(:simple_master).id }

  event.stream 'all'

  event.data do
    {  }
  end

  event.metadata do
    { timestamp: Time.now }
  end
end

Factory.define(:limit_alert, :class => Alert) do |factory|
  factory.association :account
  factory.association :cinstance

  factory.state :unread

  factory.timestamp { Time.now }
  factory.sequence(:alert_id) {|n| n }
  factory.level { Alert::ALERT_LEVELS.select{|l| l < 100}.sample }
  factory.utilization { rand + 1 }
end

Factory.define(:limit_violation, :parent => :limit_alert) do |factory|
  factory.level {|alert| Alert::ALERT_LEVELS.select{|l| l >= 100}.sample }
end
