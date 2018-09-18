require 'test_helper'
require_relative 'messages_presenter_test'

class Dashboard::NotificationsPresenterTest < Dashboard::MessagesPresenterTest

  def test_ignores_certain_notifications
    FactoryGirl.create(:notification, system_name: 'csv_data_export')
    FactoryGirl.create(:notification, system_name: 'daily_report')
    FactoryGirl.create(:notification, system_name: 'weekly_report')
    FactoryGirl.create(:notification, title: nil)
    first = FactoryGirl.create(:notification, title: 'something', created_at: 1.day.ago)
    second = FactoryGirl.create(:notification, title: 'other')

    notifications = presenter.new(Notification).all_messages

    assert_equal [second, first], notifications.to_a
  end

  protected

  def create_messages(created_at = DateTime.now)
    ids = Array.new(LIMIT) do |n|
      FactoryGirl.create(:notification, title: "Alaska_#{n}", created_at: created_at).id
    end

    Notification.where(id: ids)
  end
end
