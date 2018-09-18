module User::Roles
  extend ActiveSupport::Concern

  included do
    DEFAULT_ROLES = [:admin, :member]
    MORE_ROLES = [:contributor]
    ROLES = DEFAULT_ROLES + MORE_ROLES

    symbolize :role
    before_save :set_role

    scope :by_role, lambda { |role| where({:role => role.to_s})}

    ROLES.each do |role|
      #adds method admin? to check whether user role is admin (other roles too)
      define_method("#{role}?".to_sym) do
        role?(role)
      end

      #adds method admin! to set user role to admin (other roles too)
      define_method("#{role}!".to_sym) do
        self.update_attribute :role, role
      end
      alias_method "make_#{role}", "#{role}!"

      deprecate("#{role}!")
    end
  end

  module ClassMethods
    def admins
      by_role(:admin)
    end

    def buyer_roles
      DEFAULT_ROLES
    end

    def provider_roles
      DEFAULT_ROLES + MORE_ROLES
    end
  end

  def account_roles
    if !self.account.nil? && self.account.provider?
      User.provider_roles
    else
      User.buyer_roles # default roles
    end
  end

  def role?(role)
    self.role == role.to_sym
  end

  def superadmin?
    admin? && account && account.master?
  end

  def provider_admin?
    admin? && account && account.provider?
  end

  def set_role
    self.role ||= :member
  end
end
