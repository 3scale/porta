# frozen_string_literal: true

require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :version
  should validate_presence_of :account_id
  should validate_presence_of :schema

  test 'builtin' do
    assert_equal 'builtin', Policy::BUILT_IN_NAME
  end

  test 'sets identifier on create' do
    policy = FactoryBot.build(:policy, name: 'custom-policy', version: '7.6.5', account: FactoryBot.create(:simple_provider))
    assert_nil policy.identifier
    policy.save!
    assert_equal 'custom-policy-7.6.5', policy.identifier
  end

  test 'validates uniqueness of [account_id, name, version]' do
    persisted_policy = FactoryBot.create(:policy)

    invalid_policy = FactoryBot.build(:policy, name: persisted_policy.name, version: persisted_policy.version, account: persisted_policy.account)
    refute invalid_policy.save
    assert_equal ['has already been taken'], invalid_policy.errors[:version]

    different_version_policy = FactoryBot.build(:policy, name: persisted_policy.name, account: persisted_policy.account)
    assert different_version_policy.save

    different_name_policy = FactoryBot.build(:policy, version: persisted_policy.version, account: persisted_policy.account)
    assert different_name_policy.save

    different_provider_policy = FactoryBot.build(:policy, name: persisted_policy.name, version: persisted_policy.version, account: FactoryBot.create(:simple_provider))
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
    policy = FactoryBot.build(:policy, schema: 'invalid JSON', account: FactoryBot.create(:simple_provider))
    assert_equal ['Invalid JSON schema'], policy.errors[:schema]
    assert_nil policy.schema

    policy.schema = '{"foo": "bar"}'
    refute policy.valid?
    assert_includes policy.errors[:schema], 'The property \'#/\' did not contain a required property of \'name\' in schema http://apicast.io/policy-v1/schema#'

    policy.schema = file_fixture('policies/apicast-policy.json').read
    policy.version = policy.schema['version']
    assert policy.valid?
    assert_empty policy.errors[:schema]
  end

  test 'validates same version in schema and in field' do
    policy = FactoryBot.build(:policy, version: '0.5.0', account: FactoryBot.create(:simple_provider))
    policy.schema['version'] = '1.2.0'
    refute policy.valid?
    assert_includes policy.errors[:version], policy.errors.generate_message(:version, :mismatch)

    policy.version = Policy::BUILT_IN_NAME
    refute policy.valid?
    assert_includes policy.errors[:version], policy.errors.generate_message(:version, :builtin)

    policy.version = '1.2.0'
    assert policy.valid?
  end

  test 'find policy by id or name and version' do
    policy = FactoryBot.create(:policy, name: 'my-policy', version: '1.0')

    assert_equal policy, Policy.find_by_id_or_name_version(policy.id)
    assert_equal policy, Policy.find_by_id_or_name_version('my-policy-1.0')
  end

  test 'find policy by id or name and version when name contains spaces' do
    policy = FactoryBot.create(:policy, name: 'this is my policy', version: '1.0')

    assert_equal policy, Policy.find_by_id_or_name_version('this is my policy-1.0')
  end

  test 'update name or version also updates identifier' do
    policy = FactoryBot.create(:policy, name: 'my-policy', version: '1.0')

    policy.name = 'new-name'
    policy.save!
    assert_equal 'new-name-1.0', policy.reload.identifier

    policy.version = '1.1'
    policy.schema['version'] = policy.version
    policy.save!
    assert_equal 'new-name-1.1', policy.reload.identifier
  end

  test 'to_param' do
    policy = FactoryBot.build(:policy, name: 'my-policy', version: '1.2.0', account: FactoryBot.create(:simple_provider))
    assert_nil policy.to_param

    policy.save!
    assert_equal 'my-policy-1.2.0', policy.to_param
  end

  test 'readonly attributes changed' do
    policy = create_policy
    refute policy.readonly_attributes_changed?

    policy.name = 'new-name'
    assert policy.readonly_attributes_changed?

    policy.reload
    policy.version = '1.1'
    assert policy.readonly_attributes_changed?

    policy.reload
    policy.schema = '{}'
    assert policy.readonly_attributes_changed?
  end

  test 'in use by any proxy' do
    policy = create_policy
    refute policy.in_use?
    assert policy.idle?

    FactoryBot.create(:service, account: policy.account)
    Proxy.any_instance.expects(:find_policy_config_by).at_least_once.
                       with({ name: policy.name, version: policy.version }).
                       returns(policy.schema.slice('name', 'version', 'configuration'))

    assert policy.reload.in_use?
    refute policy.idle?
  end

  test 'forbids changes when in use' do
    policy = create_policy
    assert policy.valid?

    policy.name = 'new-name'

    policy.stubs(idle?: false)
    refute policy.valid?
    assert_match 'cannot be modified', policy.errors[:base].first

    policy.stubs(idle?: true)
    assert policy.valid?
  end

  test 'cannot be deleted when in use' do
    policy = create_policy

    policy.stubs(idle?: false)
    refute policy.destroy
    assert_match 'cannot be modified', policy.errors[:base].first

    policy.stubs(idle?: true)
    assert policy.destroy
  end

  private

  def create_policy(attributes = {})
    schema = JSON.parse(file_fixture('policies/apicast-policy.json').read)
    policy_attributes = attributes.reverse_merge name: schema['name'], version: schema['version'], schema: schema.to_json
    FactoryBot.create(:policy, policy_attributes)
  end
end
