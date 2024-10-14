# frozen_string_literal: true

class Provider::Admin::User::NotificationPreferencesController < Provider::Admin::User::BaseController
  activate_menu :account, :personal, :notification_preferences
  respond_to :html

  before_action :initialize_preferences_form, only: %i[show update]

  def show
    respond_with(@preferences)
  end

  def update
    flash[:success] = t('.success') if @preferences.update(notification_preferences_params)

    respond_with(@preferences, location: url_for(action: :show))
  end

  protected

  def notification_preferences_params
    params.require(:notification_preferences).permit(enabled_notifications: [])
  end

  private

  def initialize_preferences_form
    @preferences = NotificationPreferencesForm.new(current_user, current_user.notification_preferences)
  end
end
