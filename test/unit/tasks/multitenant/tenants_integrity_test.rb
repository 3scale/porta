# frozen_string_literal: true

require 'test_helper'

module Tasks
  module Multitenant
    class TenantsIntegrityTest < ActiveSupport::TestCase
      HEADER = "Inconsistent tenant_ids for:"

      test "reports tenant lack of integrity with belongs_to associations" do
        provider = FactoryBot.create(:simple_provider)
        wrong_buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: provider, tenant_id: provider.id + 1)
        FactoryBot.create(:simple_buyer, provider_account: provider, tenant_id: provider.id)

        expected_lines = ["Inconsistent tenant_ids for:"]
        expected_lines.concat(wrong_buyers.map { |buyer| "Account[#{buyer.id}] provider_account Account[#{provider.id}]" })

        Rails.logger.expects(:error).with { |msg| expected_lines.all? { msg.include?(_1) } }

        execute_rake_task "multitenant/tenants.rake", "multitenant:tenants:integrity"
      end

      test "reports tenant lack of integrity with has_many associations" do
        plan = FactoryBot.create(:application_plan)
        wrong_cinstances = FactoryBot.create_list(:cinstance, 2, plan: plan, tenant_id: 0)
        FactoryBot.create(:cinstance, plan: plan)

        expected_lines = []
        wrong_cinstances.each do |cinstance|
          expected_lines << %W[Account[#{cinstance.user_account.id}] Contract[#{cinstance.id}]]
          expected_lines << %W[Contract[#{cinstance.id}] Plan[#{cinstance.plan.id}]]
          expected_lines << %W[Cinstance[#{cinstance.id}] Service[#{cinstance.service.id}]]
        end

        Rails.logger.expects(:error).with do |msg|
          assert_equal(expected_lines.size + 1, msg.lines.size) &&
            msg.include?(HEADER) &&
            expected_lines.all? { msg_includes_pair?(msg, _1) }
        end

        execute_rake_task "multitenant/tenants.rake", "multitenant:tenants:integrity"
      end

      test "reports tenant lack of integrity with complex primary keys" do
        plan = FactoryBot.create(:application_plan)
        feature = FactoryBot.create(:feature, featurable: plan.issuer, tenant_id: 0)
        plan.features << feature

        expected_lines = []
        expected_lines << ["Plan[#{plan.id}]", "FeaturesPlan[#{plan.id}, #{feature.id}]"]
        expected_lines << %W[Service[#{plan.issuer.id}] Feature[#{feature.id}]]

        Rails.logger.expects(:error).with do |msg|
          assert_equal(expected_lines.size + 1, msg.lines.size) &&
            msg.include?(HEADER) &&
            expected_lines.all? { msg_includes_pair?(msg, _1) }
        end

        execute_rake_task "multitenant/tenants.rake", "multitenant:tenants:integrity"
      end

      private

      def msg_includes_pair?(msg, pair)
        first = Regexp.escape(pair[0])
        second = Regexp.escape(pair[1])
        msg.match? /^#{first} [^ ]+ #{second}|#{second} [^ ]+ #{first}$/
      end
    end
  end
end
