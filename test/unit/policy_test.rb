# frozen_string_literal: true

require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  test 'validates uniqueness of [account_id, name, version]' do
    persisted_policy = FactoryBot.create(:policy)

    invalid_policy = FactoryBot.build(:policy, name: persisted_policy.name, version: persisted_policy.version, account: persisted_policy.account)
    refute invalid_policy.save
    assert_equal ['has already been taken'], invalid_policy.errors[:version]

    different_version_policy = FactoryBot.build(:policy, name: persisted_policy.name, account: persisted_policy.account)
    assert different_version_policy.save

    different_name_policy = FactoryBot.build(:policy, version: persisted_policy.version, account: persisted_policy.account)
    assert different_name_policy.save

    different_provider_policy = FactoryBot.build(:policy, name: persisted_policy.name, version: persisted_policy.version)
    assert different_provider_policy.save
  end
end
