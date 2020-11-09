# frozen_string_literal: true

class AdminSection

  PERMISSIONS = %I[ portal finance settings partners monitoring plans policy_registry ].freeze
  LABELS_RESUME = {
    portal: 'developer portal',
    finance: 'customer billing',
    settings: 'settings pages',
    partners: 'developer accounts, applications',
    monitoring: 'analytics',
    plans: 'API backends, API products',
    policy_registry: 'policies'
  }
  SERVICE_PERMISSIONS = %i[partners plans monitoring]
  NO_SERVICE_PERMISSIONS = PERMISSIONS - SERVICE_PERMISSIONS

  def self.permissions
    if ThreeScale.master_on_premises?
      PERMISSIONS - %i(finance)
    else
      PERMISSIONS
    end
  end

  def self.permissions_for_account(account)
    account.provider_can_use?(:policy_registry) ? permissions : (permissions - %i[policy_registry])
  end

  SECTIONS = PERMISSIONS + %I[ services ]

  def self.sections
    permissions + %i(services)
  end

  LABELS = SECTIONS.map do |section|
    [ section, I18n.t(section.to_s, scope: :admin_sections)]
  end.to_h

  private_constant :LABELS, :PERMISSIONS, :SECTIONS

  def self.labels(roles)
    LABELS.values_at(*Array(roles).map(&:to_sym)).join(', ')
  end

  def self.labels_resume(roles)
    LABELS_RESUME.values_at(*Array(roles).map(&:to_sym)).join(', ')
  end
end
