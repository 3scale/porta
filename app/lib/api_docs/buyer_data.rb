# frozen_string_literal: true

module ApiDocs
  class BuyerData < AccountData

    def apps
      @apps ||= bought_applications.latest.live
    end

    def data_items
      %w[app_keys app_ids user_keys client_ids client_secrets service_hosts]
    end

    protected

    def bought_applications
      @account.bought_cinstances
    end

    def accessible_services
      @account.provider_account.services.accessible.where(id: bought_applications.select(:service_id))
    end
  end
end
