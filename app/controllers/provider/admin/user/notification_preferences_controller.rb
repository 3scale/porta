class Provider::Admin::User::NotificationPreferencesController < Provider::Admin::User::BaseController
  activate_menu :account, :personal, :notification_preferences
  respond_to :html

  before_action :initialize_preferences_form, only: [:show, :update]

  def show
    respond_with(@preferences_form)
  end

  def update
    if @preferences_form.update_attributes(notification_preferences_params)
      flash[:success] = 'Preferences updated'
    end

    respond_with(@preferences_form, location: url_for(action: :show))
  end

  protected

  def notification_preferences_params
    params.require(:notification_preferences).permit(enabled_notifications: [])
  end

  private

  def initialize_preferences_form
    @preferences_form = NotificationPreferencesForm.new(
      current_user, current_user.notification_preferences)
  end
end
