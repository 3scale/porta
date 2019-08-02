# frozen_string_literal: true

module ApiAuthentication::ByProviderKey
  extend ActiveSupport::Concern
  included do
    include ApiAuthentication::HttpAuthentication
  end

  def logged_in?
    !current_account.nil?
  end

  def current_account
    @current_account ||= if current_user
                           current_user.account
                         elsif provider_key.present?
                           Account
                               .providers_with_master
                               .by_self_domain(request.host)
                               .find_by_provider_key(provider_key)
                         end
  end

  private

  def provider_key
    return @_provider_key if instance_variable_defined?(:@_provider_key)
    @_provider_key = params.fetch(provider_key_param_name, &method(:http_authentication))
  end

  def provider_key_param_name
    :provider_key
  end
end
