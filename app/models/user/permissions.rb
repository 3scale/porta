# frozen_string_literal: true

require 'admin_section'

module User::Permissions
  extend ActiveSupport::Concern

  ATTRIBUTES = %I[role member_permission_ids member_permission_service_ids].freeze

  included do
    has_many :member_permissions, dependent: :destroy, autosave: true

    attr_accessible :member_permission_service_ids, :member_permission_ids, :allowed_sections, :allowed_service_ids

    alias_attribute :allowed_sections, :member_permission_ids
    alias_attribute :allowed_service_ids, :member_permission_service_ids
  end

  def has_permission?(permission)
    return true if account.provider? && admin?
    return false if account.buyer?

    admin_sections.include?(permission.to_sym).tap do |check|
      logger.debug "~> #{username} has_permission?(#{permission}) => #{check}"
    end
  end

  def admin_sections
    @_admin_sections ||= Set.new(member_permissions.map(&:admin_section)).freeze
  end

  def admin_sections=(sections)
    existing_permissions = member_permissions.index_by(&:section_name)

    existing_sections = existing_permissions.keys
    desired_sections = sections.map(&:to_s)

    keep = existing_sections & desired_sections
    create = desired_sections - existing_sections

    keep_permissions = existing_permissions.values_at(*keep)
    new_permissions = create.map { |section| member_permissions.build(admin_section: section) }

    self.member_permissions = keep_permissions + new_permissions + [services_member_permission].compact
  ensure
    @_admin_sections = nil
  end

  # returns all permissions (:portal, :finance, :settings, :partners, :monitoring, :plans, :policy_registry) for admins
  # and the allowed ones for member users
  def member_permission_ids
    admin? ? AdminSection.permissions : admin_sections - [:services]
  end

  def member_permission_ids=(roles)
    self.admin_sections = (Array(roles).reject(&:blank?).map(&:to_sym) & AdminSection.permissions)
  end

  def member_permission_service_ids=(service_ids)
    if service_ids.is_a? Array
      # remove all non-integer values
      service_ids = service_ids.map { Integer(_1, exception: false) }.compact_blank
      member_permission = services_member_permission || member_permissions.build(admin_section: :services)
      member_permission.service_ids = service_ids & existing_service_ids
    elsif service_ids.blank?
      self.member_permissions = member_permissions - [services_member_permission].compact
    end
  ensure
    @_admin_sections = nil
  end

  def existing_service_ids
    account.try(:service_ids) || []
  end

  # TODO: this is suboptimal to do on 'read', it should be done on write
  # but then it is much harder to test MemberPermission#service_ids=
  # returns [] if no services are enabled, and nil if all (current and future) services are enabled
  def member_permission_service_ids
    return nil if admin? || !services_member_permission

    permitted_service_ids = services_member_permission.try(:service_ids) || []
    permitted_service_ids & existing_service_ids
  end

  def services_member_permission
    member_permissions.find { |permission| permission.admin_section == :services }
  end

  def has_access_to_service?(service)
    has_access_to_all_services? || services_member_permission&.has_service?(service)
  end

  # Returns:
  #   :none - if no services are allowed
  #   :all - if all services are allowed for the selected service-related permissions
  #   :selected - if a subset of services is allowed for the selected service-related permissions
  def permitted_services_status
    if admin? || (service_permissions_selected? && member_permission_service_ids.nil?)
      :all
    elsif service_permissions_selected? && member_permission_service_ids.present?
      :selected
    else
      :none
    end
  end

  def has_access_to_all_services?
    permitted_services_status == :all
  end

  # Returns whether the user has access to any service-related permissions (partners, plans, monitoring or policy_registry)
  def service_permissions_selected?
    (member_permission_ids & AdminSection::SERVICE_PERMISSIONS).any?
  end

  def access_to_service_admin_sections?
    service_permissions_selected? && accessible_services?
  end

  def reload(*)
    @_admin_sections = nil
    super
  end
end
