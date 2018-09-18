# frozen_string_literal: true

class AuthenticationProvider::RedhatCustomerPortal < AuthenticationProvider::Keycloak

  CONFIG_ATTRIBUTES = %i[client_id client_secret realm system_name skip_ssl_certificate_verification].freeze
  private_constant :CONFIG_ATTRIBUTES

  attr_accessible(*CONFIG_ATTRIBUTES, :account)

  def self.build(options = {})
    config = ThreeScale.config.redhat_customer_portal.to_h
               .slice(*CONFIG_ATTRIBUTES)
               .merge(options)
               .reverse_merge(system_name: RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME)

    new do |provider|
      provider.assign_attributes(config)
      provider.readonly!
      provider.freeze
    end
  end
end
