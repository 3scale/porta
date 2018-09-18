module ApiDocs
  class BuyerData < AccountData

    def apps
      @apps ||= @account.bought_cinstances.latest.live
    end

    def data_items
      %w(app_keys app_ids user_keys client_ids client_secrets)
    end

  end
end
