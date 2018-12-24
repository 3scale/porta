FactoryBot.define do
  factory(:notification) do
    association :user, factory: :simple_user
    association :event
    system_name NotificationMailer.event_mapping.keys.first.to_s
  end

  factory(:notification_with_parent_event, parent: :notification) do
    event do
      FactoryBot.create(:event, data: { parent_event_id: FactoryBot.create(:event).event_id })
    end
  end
end