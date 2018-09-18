class CreateEmailNotificationTemplateOnMasterAccount < ActiveRecord::Migration

  def self.up
    return unless Account.exists?(:master => true)

    template_path = "#{Rails.root}/lib/themes/3scale"
    template = LiquidPage.read_page('signup_notification_email', template_path)

    page = Account.master.liquid_pages.find_by_title('signup_notification_email')
    page.update_attributes :content => template
  end

  def self.down
  end

end
