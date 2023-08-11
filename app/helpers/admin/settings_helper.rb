module Admin::SettingsHelper
  def monthly_charging_status(settings)
    txt = 'Monthly charging is '
    txt << if settings.monthly_charging_enabled?
             'enabled'
           else
             'disabled'
           end

  end

  def toggle_monthly_charging_text(settings)
    if settings.monthly_charging_enabled?
      'Disable'
    else
      'Enable'
    end
  end

  def toggle_monthly_charging_button_id(settings)
    "#{toggle_monthly_charging_text(settings)}-setting-monthly_charging"
  end
end
