# requires:
#   * AuthenticatedSystem
#   * AccessControl (for unauthorized!)
#   * SiteAccountSupport (for provider_domain?)
#
# provides
module PermissionSystem

  def self.included(base)
    base.extend(ClassMethods)
  end

  protected
    def require_permission(name)
      return true unless current_account && provider_domain?
      has_permission?(name) || unauthorized!
    end

    def has_permission?(name)
      current_user && current_user.has_permission?(name)
    end

    def provider_user?
      current_account && current_account.provider?
    end

    def provider_admin?
      provider_user? && current_user.admin?
    end

  module ClassMethods

    # Before filter
    #
    #   require_permission :foo, :only => [:index] ...
    #
    def require_permission(name, options={})
      before_action(options) do | controller |
        controller.send(:require_permission, name.to_s)
      end
    end

    # Adds a before filter
    #
    #   require_provider_admin :only => [:show]....
    #
    def require_provider_admin(options={})
      before_action(options) do | controller |
        controller.send(:provider_admin?) || controller.send("unauthorized!".to_sym)
      end
    end

    # Adds a before filter
    #
    #   require_provider_user :except => [:destroy]
    #
    def require_provider_user(options={})
      before_action(options) do | controller |
        controller.send(:provider_user?) || controller.send("unauthorized!".to_sym)
      end
    end

  end
end
