# frozen_string_literal: true

class NotificationPreferencesRepresenter < ThreeScale::Representer
  include ThreeScale::JSONRepresenter

  property :preferences, as: :notification_preferences

  # NotificationPreferences.available_notifications.each do |notification|
  #   property notification, getter: ->(*) { preferences[notification.to_s] }
  # end
end
