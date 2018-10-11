module User::Permissions
  extend ActiveSupport::Concern

  ATTRIBUTES = %I[ role member_permission_ids member_permission_service_ids ]

  included do
    has_many :member_permissions, dependent: :destroy
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

  def member_permission_ids=(roles)
    self.admin_sections = Array(roles).reject(&:blank?)
  end

  def admin_sections=(sections)
    existing_permissions = member_permissions.index_by(&:section_name)

    existing_sections = existing_permissions.keys
    desired_sections = sections.map(&:to_s)

    keep = existing_sections & desired_sections
    create = desired_sections - existing_sections

    keep_permissions = existing_permissions.values_at(*keep)
    new_permissions = create.map { |section| member_permissions.build(admin_section: section) }

    self.member_permissions = keep_permissions + new_permissions
  ensure
    @_admin_sections = nil
  end

  def member_permission_service_ids=(service_ids)
    services_section = [:services]

    if service_ids.present?
      self.admin_sections = admin_sections | services_section
      services_member_permission.service_ids = service_ids
    else
      self.admin_sections = admin_sections - services_section
    end
  end

  # TODO: this is suboptimal to do on 'read', it should be done on write
  # but then it is much harder to test MemberPermission#service_ids=
  def member_permission_service_ids
    permitted_service_ids = services_member_permission.try(:service_ids) || []
    existing_service_ids = account.try(:service_ids) || []
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
