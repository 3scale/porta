module User::Permissions
  extend ActiveSupport::Concern

  ATTRIBUTES = %I[ role member_permission_ids member_permission_service_ids ]

  included do
    has_many :member_permissions, dependent: :destroy

    attr_accessible :member_permission_service_ids, :member_permission_ids, :allowed_sections, :allowed_service_ids

    alias_attribute :allowed_sections, :member_permission_ids
    alias_attribute :allowed_service_ids, :member_permission_service_ids
  end

  #TODO: this is repeated from bcms_hacks plugins because of some loading problem
  def has_permission?(permission)
    return true  if account.provider? && admin?
    return false if account.buyer?

    # check = Permission.count(:include => {:groups => :users}, :conditions => ["users.id = ? and permissions.name=?", id, permission]) > 0

    admin_sections.include?(permission.to_sym).tap do |check|
      logger.info "~> #{username} has_permission?(#{permission}) => #{check}"
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

    all_permissions = keep_permissions + new_permissions
    # keep service permissions as they were
    all_permissions << services_member_permission if services_member_permission

    self.member_permissions = all_permissions
  ensure
    @_admin_sections = nil
  end

  # returns all permissions (:portal, :finance, :settings, :partners, :monitoring, :plans) for admins
  # and the allowed ones for member users
  def member_permission_ids
    admin? ? AdminSection.permissions : admin_sections - [:services]
  end

  def member_permission_ids=(roles)
    self.admin_sections = Array(roles).reject(&:blank?)
  end

  def member_permission_service_ids=(service_ids)
    if service_ids.present?
      service_ids = Array(service_ids).reject(&:blank?).map(&:to_i)
      if services_member_permission
        services_member_permission.service_ids = service_ids & existing_service_ids
        services_member_permission.save
      else
        new_services_member_permissions = member_permissions.build( admin_section: :services,
                                                                      service_ids: service_ids)
        member_permissions << new_services_member_permissions
      end
    elsif services_member_permission
      self.member_permissions = member_permissions - [services_member_permission]
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
    services_permission = services_member_permission
    services_permission && services_permission.has_service?(service) || has_access_to_all_services?
  end

  # Lack of the services section means it is the old permission system where everyone had access
  # to every service. So to limit the scope only for new users, we start adding this permission.
  def has_access_to_all_services?
    !admin_sections.include?(:services) || admin?
  end

  def forbidden_some_services?
    !has_access_to_all_services? && account.provider_can_use?(:service_permissions)
  end

  def reload(*)
    @_admin_sections = nil
    super
  end
end
