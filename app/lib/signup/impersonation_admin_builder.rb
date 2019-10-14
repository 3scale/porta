# frozen_string_literal: true

class Signup::ImpersonationAdminBuilder
  def self.build(account:)
    config = ThreeScale.config.impersonation_admin
    username = config['username']
    impersonation_admin = account.users.new(
      {
        username: username,
        email: "#{username}+#{account.self_domain}@#{config['domain']}",
        first_name: '3scale',
        last_name: 'Admin',
        state: 'active'
      },
      without_protection: true)
    impersonation_admin.role = :admin
    impersonation_admin.signup_type = :minimal
    impersonation_admin
  end
end
