# frozen_string_literal: true

class AdminSection
  PERMISSIONS = %i[portal finance settings partners monitoring plans policy_registry].freeze
  SERVICE_PERMISSIONS = %i[partners plans monitoring policy_registry].freeze
  NO_SERVICE_PERMISSIONS = PERMISSIONS - SERVICE_PERMISSIONS
  SECTIONS = PERMISSIONS + %i[services]

  def self.permissions
    if ThreeScale.master_on_premises?
      PERMISSIONS - %i[finance]
    else
      PERMISSIONS
    end
  end

  def self.permissions_for_account(account)
    account.provider_can_use?(:policy_registry) ? permissions : (permissions - %i[policy_registry])
  end

  def self.sections
    permissions + %i(services)
  end

  private_constant :PERMISSIONS, :SECTIONS
end
