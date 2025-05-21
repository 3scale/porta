# frozen_string_literal: true

class Admin::Api::Personal::NotificationPreferencesController < Admin::Api::Personal::BaseController
  wrap_parameters :notification_preferences

  representer NotificationPreferences

  # Notification Preferences List
  # GET /admin/api/personal/notification_preferences.json
  def index
    respond_with current_user.notification_preferences
  end

  # Notification Preferences Update
  # PUT /admin/api/personal/notification_preferences.json
  def update
    prefs = current_user.notification_preferences
    prefs.update(new_preferences: notification_preferences_params)
    respond_with prefs.reload
  end

  private

  def notification_preferences_params
    params.require(:notification_preferences).permit(*NotificationPreferences.available_notifications)
  end
end
