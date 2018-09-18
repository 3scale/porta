class ChangeLegalPgLinks < ActiveRecord::Migration
  def up
    change_column :settings, :cc_terms_path,   :string, :default => "/termsofservice"
    change_column :settings, :cc_privacy_path, :string, :default => "/privacypolicy"
    change_column :settings, :cc_refunds_path, :string, :default => "/refundpolicy"
  end

  def down
    change_column :settings, :cc_terms_path,   :string, :default => "termsofservice"
    change_column :settings, :cc_privacy_path, :string, :default => "privacypolicy"
    change_column :settings, :cc_refunds_path, :string, :default => "refundpolicy"
  end
end
