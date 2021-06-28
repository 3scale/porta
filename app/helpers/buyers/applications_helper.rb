# frozen_string_literal: true

module Buyers::ApplicationsHelper
  include ::ApplicationsHelper

  def new_application_form_data(provider:, buyer:, cinstance: nil)
    data = {
      'create-application-path': admin_buyers_account_applications_path(buyer),
      buyer: BuyerDecorator.new(buyer).new_application_data.to_json,
      'most-recently-updated-products': most_recently_updated_products.to_json,
      'products-count': raw_products.size,
    }
    data.merge super(provider, cinstance)
  end

  protected

  # TODO: need to refactor this method, there is no default return value
  def create_application_link_href(account)
    if account.bought_cinstances.size.zero?
      new_admin_buyers_account_application_path(account)
    elsif can?(:admin, :multiple_applications)
      if can?(:see, :multiple_applications)
        new_admin_buyers_account_application_path(account)
      else
        admin_upgrade_notice_path(:multiple_applications)
      end
    end
  end
end
