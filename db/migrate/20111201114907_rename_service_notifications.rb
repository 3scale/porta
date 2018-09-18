class RenameServiceNotifications < ActiveRecord::Migration
  def self.up
    Service.all.each do |service|
      notification = service.notification_settings
      next unless notification.present?

      notification[:email_provider] = notification.delete(:provider)
      notification[:email_buyer] = notification.delete(:buyer)
      notification[:web_buyer] = notification[:web_provider] = notification.delete(:web)

      notification.reject! { |key,value| value.nil? }
      service.update_attribute :notification_settings, notification
    end
  end

  def self.down
    Service.all.each do |service|
      notification = service.notification_settings
      next unless notification.present?

      notification[:provider] = notification.delete(:email_provider)
      notification[:buyer] = notification.delete(:email_buyer)
      notification[:web] = (notification.delete(:web_provider) + notification.delete(:web_buyer)).uniq

      service.update_attribute :notification_settings, notification
    end
  end
end
