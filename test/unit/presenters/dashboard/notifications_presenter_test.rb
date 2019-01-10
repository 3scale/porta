require 'test_helper'
require_relative 'messages_presenter_test'

class Dashboard::NotificationsPresenterTest < Dashboard::MessagesPresenterTest

  def test_ignores_certain_notifications
    FactoryBot.create(:notification, system_name: 'csv_data_export')
    FactoryBot.create(:notification, system_name: 'daily_report')
    FactoryBot.create(:notification, system_name: 'weekly_report')
    FactoryBot.create(:notification, title: nil)
    first = FactoryBot.create(:notification, title: 'something', created_at: 1.day.ago)
    second = FactoryBot.create(:notification, title: 'other')

    notifications = presenter.new(Notification).all_messages

    assert_equal [second, first], notifications.to_a
  end

  protected

  def create_messages(created_at = DateTime.now)
    ids = Array.new(LIMIT) do |n|
      FactoryBot.create(:notification, title: "Alaska_#{n}", created_at: created_at).id
    end

    Notification.where(id: ids)
  end
end
