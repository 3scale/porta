class AddSslVerificationToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :skip_ssl_certificate_verification, :boolean, default: false
  end
end
