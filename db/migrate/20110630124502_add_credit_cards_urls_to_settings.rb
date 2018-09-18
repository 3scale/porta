class AddCreditCardsUrlsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :cc_terms_path, :string, :default => "termsofservice"
    add_column :settings, :cc_privacy_path, :string, :default => "privacypolicy"
    add_column :settings, :cc_refunds_path, :string, :default => "refundpolicy"
  end

  def self.down
    remove_column :settings, :cc_terms_path
    remove_column :settings, :cc_privacy_path
    remove_column :settings, :cc_refunds_path
  end
end
