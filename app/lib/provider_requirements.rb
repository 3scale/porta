module ProviderRequirements

  def self.included(base)
    base.extend(ClassMethods)
  end

  def provider_user?
    current_account and current_account.provider?
  end

  def provider_admin?
    provider_user? and current_user.admin?
  end

  module ClassMethods

    def require_provider_admin(options={})
      before_action(options) do | controller |
        controller.send(:provider_admin?) || unauthorized!
      end
    end

    def require_provider_user(options={})
      before_action(options) do | controller |
        controller.send(:provider_user?) || unauthorized!
      end
    end

  end
end
