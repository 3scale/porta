class AddSignupNotificationLiquidToDemoAccount < ActiveRecord::Migration

  def self.up
    if account = Account.find_by_domain("demo.3scale.net")
      account.liquid_pages.create(:title => "signup_notification", :content => "Thank you for signing up for access ...")
    end
  end

  def self.down
    if account = Account.find_by_domain("demo.3scale.net")
      account.liquid_pages.find_by_title("signup_notification").delete rescue nil
    end
  end
end
