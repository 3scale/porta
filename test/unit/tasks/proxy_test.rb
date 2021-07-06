# frozen_string_literal: true

require 'test_helper'

module Tasks
  class ProxyTest < ActiveSupport::TestCase
    class ResetProxyConfigChangeHistoryTest < ActiveSupport::TestCase
      setup do
        @providers = FactoryBot.create_list(:provider_account, 3)

        @proxy_with_legit_change = proxies.last
        @legit_change_date = 2.minutes.from_now.freeze
        proxy_with_legit_change.affecting_change_history.update_column(:updated_at, legit_change_date) # so change history of this proxy has been updated

        @providers << FactoryBot.create(:provider_account) # change history for the proxy associated with this account does not exist
        @proxy_without_change_history = proxies.last
        ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).delete_all
        @reset_date = Time.utc(1900, 1, 1).freeze
      end

      attr_reader :providers, :proxy_with_legit_change, :legit_change_date, :proxy_without_change_history, :reset_date

      test 'creates missing change history' do
        refute ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?
        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history'
        assert ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?
      end

      test 'resets change history of all providers whose proxy config is untouched' do
        assert_did_not_reset_proxies_without_legit_change
        assert_did_not_reset_proxy_with_legit_change
        refute ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?

        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history'

        ProxyConfigAffectingChange.where(proxy: proxies.to_a.values_at(0, 1, 3)).each { |tracking_object| assert_equal reset_date, tracking_object.updated_at }
        assert_did_not_reset_proxy_with_legit_change
      end

      test 'resets change history of given account id' do
        assert_did_not_reset_proxies_without_legit_change
        assert_did_not_reset_proxy_with_legit_change
        refute ProxyConfigAffectingChange.where(proxy: proxy_without_change_history).exists?

        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history', providers.last.id

        assert_did_not_reset_proxies_without_legit_change
        assert_did_not_reset_proxy_with_legit_change
        assert_equal reset_date, proxies.last.affecting_change_history.updated_at
      end

      test 'reset change history of legit tracking record is a no-op' do
        assert_did_not_reset_proxy_with_legit_change
        execute_rake_task 'proxy.rake', 'proxy:reset_config_change_history', providers[2].id
        assert_did_not_reset_proxy_with_legit_change
      end

      protected

      def proxies
        Proxy.where(service: Service.where(account: providers)).order(:id)
      end

      def assert_did_not_reset_proxies_without_legit_change
        ProxyConfigAffectingChange.where(proxy: proxies[0..1]).each { |tracking_object| assert tracking_object.created_at == tracking_object.updated_at }
      end

      def assert_did_not_reset_proxy_with_legit_change
        assert_equal legit_change_date.to_i, proxy_with_legit_change.affecting_change_history.updated_at.to_i
      end
    end
  end
end
