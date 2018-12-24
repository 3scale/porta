Factory.define(:notification) do |factory|
  factory.association :user, factory: :simple_user
  factory.association :event
  factory.system_name NotificationMailer.event_mapping.keys.first.to_s
end

Factory.define(:notification_with_parent_event, parent: :notification) do |factory|
  factory.event do
    FactoryBot.create(:event, data: { parent_event_id: FactoryBot.create(:event).event_id })
  end
end
