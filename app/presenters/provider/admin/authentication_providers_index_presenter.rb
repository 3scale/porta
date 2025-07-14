# frozen_string_literal: true

class Provider::Admin::AuthenticationProvidersIndexPresenter
  include ::Draper::ViewHelpers
  include System::UrlHelpers.system_url_helpers

  attr_reader :account

  def initialize(account:)
    @account = account
  end

  def authentication_providers
    @authentication_providers ||= authentication_provider_kinds(account)
  end

  private

  def authentication_provider_kinds(account)
    available = AuthenticationProvider.available
    indexed = account.authentication_providers.where(type: available.map(&:name)).group_by(&:type)

    available.each do |model|
      indexed[model.name] = model.new if indexed[model.name].blank?
    end

    indexed.values.flatten.sort_by { |a| a.to_param.to_s }.reverse
  end
end
