# frozen_string_literal: true

require 'test_helper'

class Api::AccountHelperTest < ActionView::TestCase
  # TODO: this is not an independent test. There are too many dependencies among the helpers and this should be refactored
  include MenuHelper
  include ApplicationHelper
  include ButtonsHelper
  include AccountHelper

  setup do
    @provider = FactoryBot.create(:simple_provider, provider_account: master_account)
  end

  attr_reader :provider
  delegate :can?, to: :ability

  class ProviderLoggedIn < Api::AccountHelperTest
    def current_user
      @current_user ||= FactoryBot.create(:active_admin, account: provider)
    end

    test 'delete_buyer_link for a developer account' do
      developer = FactoryBot.create(:simple_buyer, provider_account: provider)

      link = delete_buyer_link(developer)

      assert_includes link, "href=\"#{admin_buyers_account_path(developer)}\""

      assert_does_not_contain link, /data-confirm=\"[^=]*in 15 days/
      assert_does_not_contain link, /data-confirm=\"[^=]*#{15.days.from_now.to_date.to_s(:long)}/
      assert_contains link, /data-confirm=\"[^=]*Are you sure you want to delete/
    end
  end

  class MasterLoggedIn < Api::AccountHelperTest
    def current_user
      @current_user ||= master_account.admin_users.first!
    end

    test 'delete_buyer_link for a tenant account' do
      link = delete_buyer_link(provider)

      assert_includes link, "href=\"#{admin_buyers_account_path(provider)}\""

      assert_contains link, /data-confirm=\"[^=]*in 15 days/
      assert_contains link, /data-confirm=\"[^=]*#{15.days.from_now.to_date.to_s(:long)}/
      assert_does_not_contain link, /data-confirm=\"[^=]*Are you sure you want to delete/
    end
  end

  private

  def current_account
    current_user.account
  end

  def ability
    Ability.new(current_user)
  end
end
