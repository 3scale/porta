# frozen_string_literal: true

require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :version
  should validate_presence_of :account_id
  should validate_presence_of :schema

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

  test 'validates that account is a tenant' do
    policy = FactoryBot.build(:policy, account: nil)

    policy.account = FactoryBot.build(:simple_buyer)
    refute policy.valid?
    assert_equal ['must be a tenant'], policy.errors[:account]

    policy.account = master_account
    refute policy.valid?
    assert_equal ['must be a tenant'], policy.errors[:account]

    policy = policy.account = FactoryBot.build(:simple_provider)
    assert policy.valid?
    assert_empty policy.errors[:account]
  end

  test 'validates schema' do
    policy = FactoryBot.build(:policy, schema: 'invalid JSON')
    refute policy.valid?
    assert_equal ['Invalid JSON'], policy.errors[:schema]

    policy.schema = '{"foo": "bar"}'
    refute policy.valid?
    assert_includes policy.errors[:schema], 'The property \'#/\' did not contain a required property of \'name\' in schema http://apicast.io/policy-v1/schema#'

    policy.schema = file_fixture('policies/apicast-policy.json').read
    assert policy.valid?
    assert_empty policy.errors[:schema]
  end

  test 'find policy by id or name and version' do
    Policy.expects(:find_by).with({ id: 1 })
    Policy.find_by_id_or_name_version(1)

    Policy.expects(:find_by).with({ name: 'my_policy', version: '1.0' })
    Policy.find_by_id_or_name_version('my_policy-1.0')
  end

  test 'find policy by name and version when name contains dashes' do
    Policy.expects(:find_by).with({ name: 'my-policy', version: '1.0' })
    Policy.find_by_id_or_name_version('my-policy-1.0')
  end
end
