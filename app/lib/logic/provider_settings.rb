# frozen_string_literal: true

# Those settings are here just because there is not yet enough
# separated logic so that they have their own module.
#
module Logic
  module ProviderSettings
    def can_create_service?
      provider? or raise ProviderOnlyMethodCalledError
      settings.multiple_services.allowed? && provider_constraints.can_create_service?
    end

    def can_create_user?
      provider? or raise ProviderOnlyMethodCalledError
      settings.multiple_users.allowed? && provider_constraints.can_create_user?
    end

    def web_hooks_allowed?
      settings.web_hooks.allowed?
    end

    def forum_enabled?
      # TODO: are there some other conditions required for that?
      try(:settings).try!(:forum_enabled?) && provider_can_use?(:forum)
    end

    def service_items_in_menu?
      !multiservice?
    end

    def multiservice?
      account = buyer? ? provider_account : self
      account.multiple_accessible_services?
    end

    def multiple_accessible_services?(scope = nil)
      accessible_services.merge(scope).size > 1
    end

    def reload(*)
      @_services_size = nil
      super
    end

    def has_visible_services_with_plans?
      settings.visible_ui?(:service_plans) && settings.multiple_services.visible? && service_plans.published.exists?
    end
  end
end
