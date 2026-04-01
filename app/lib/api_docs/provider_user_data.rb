# frozen_string_literal: true

module ApiDocs
  class ProviderUserData < ProviderData
    attr_reader :user, :account

    def initialize(user)
      @user = user
      super user.account
    end

    def access_token
      [{ name: @user.access_tokens.empty? ? 'First create an access token in the Personal Settings section.' : 'Paste a personal access token with the correct permissions.', value: '' }]
    end

    def service_tokens
      tokens = @user.decorate.accessible_services_with_token.map do |service|
        { name: service.name, value: service.active_service_token.value }
      end
      tokens.presence || [{ name: "You don't have access to any services, contact an administrator of this account.", value: '' }]
    end

    def data_items
      super + %w[access_token service_tokens]
    end

    def apps
      @user_apps ||= @account.provided_cinstances.where(service: user.accessible_services).latest.live
    end
  end
end
