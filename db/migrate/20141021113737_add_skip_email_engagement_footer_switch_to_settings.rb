class AddSkipEmailEngagementFooterSwitchToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :skip_email_engagement_footer_switch, :string, :null => false, :default => "denied"

    Settings.connection.schema_cache.clear!
    Settings.reset_column_information

    Settings.joins(:account).where(accounts: {"provider"=> true}).update_all("skip_email_engagement_footer_switch='visible'")
  end

  def self.down
    remove_column :settings, :skip_email_engagement_footer_switch
  end
end
