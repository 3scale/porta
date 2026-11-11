require 'test_helper'

class AuditedHacksTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    Audited.audit_class.delete_all
  end

  def test_user_synch
    User.current = @provider.provider_account.users.first!

    stub_core_change_provider_key(@provider.provider_key)

    Cinstance.with_synchronous_auditing do
      assert_difference Audited.audit_class.method(:count) do
        @provider.bought_cinstance.change_user_key!
      end
    end

    audit = Audited.audit_class.last!
    assert_equal User.current, audit.user
  end

  class SensitiveAuditTest < self
    test 'sensitive account settings filter value in audit on create' do
      [AccountSetting::SSOKey, AccountSetting::JanrainApiKey, AccountSetting::CMSToken].each do |klass|
        record = nil
        klass.with_synchronous_auditing do
          record = klass.create!(account: @provider, value: 'super_secret', tenant_id: @provider.tenant_id)
        end

        audit = record.audits.last!
        assert_equal 'create', audit.action
        assert_equal '[FILTERED]', audit.audited_changes['value'], "#{klass} should filter value on create"
        assert_not_includes audit.audited_changes.values.flatten, 'super_secret'
      end
    end

    test 'sensitive account settings filter value in audit on update' do
      record = AccountSetting::SSOKey.create!(account: @provider, value: 'old_secret', tenant_id: @provider.tenant_id)

      AccountSetting::SSOKey.with_synchronous_auditing do
        record.update!(value: 'new_secret')
      end

      audit = record.audits.where(action: 'update').last!
      assert_equal ['[FILTERED]', '[FILTERED]'], audit.audited_changes['value']
      assert_not_includes audit.audited_changes.values.flatten, 'old_secret'
      assert_not_includes audit.audited_changes.values.flatten, 'new_secret'
    end

    test 'non-sensitive account settings keep value in audit' do
      record = nil
      AccountSetting::BgColour.with_synchronous_auditing do
        record = AccountSetting::BgColour.create!(account: @provider, value: '#abcdef', tenant_id: @provider.tenant_id)
      end

      audit = record.audits.last!
      assert_equal '#abcdef', audit.audited_changes['value']
    end
  end

  class LoggingTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    setup do
      @provider = FactoryBot.create(:simple_provider)
      User.current = FactoryBot.create(:admin, account: provider)

      @audit_class = Audited.audit_class
      @audit = FactoryBot.build(:audit, provider_id: provider.id)

      audit_class.delete_all
    end

    attr_reader :provider, :audit_class, :audit

    test '#logging_to_stdout?' do
      Features::LoggingConfig.config.stubs(audits_to_stdout: false)
      refute audit_class.logging_to_stdout?
      refute audit.logging_to_stdout?

      Features::LoggingConfig.config.stubs(audits_to_stdout: true)
      assert audit_class.logging_to_stdout?
      assert audit.logging_to_stdout?
    end

    test 'logging to stdout disabled' do
      audit_class.stubs(:logging_to_stdout? => false)
      audit_class.any_instance.expects(:log_to_stdout).never # I know, expecting a method never to be invoked sucks :/
      assert audit.save!
    end

    test 'logging to stdout enabled' do
      audit_class.stubs(:logging_to_stdout? => true)
      audit_class.any_instance.expects(:log_to_stdout).once
      assert audit.save!

      audit.version = 2
      audit_class.any_instance.expects(:log_to_stdout).never
      assert audit.save!
    end

    test 'logging to stdout only on create' do
      audit_class.stubs(:logging_to_stdout? => true)
      audit_class.any_instance.expects(:log_to_stdout).once
      assert audit.save!
    end

    test 'log to stdout' do
      audit.stubs(log_trail: 'log message')
      Rails.logger.expects(:info).with('log message')
      audit.log_to_stdout
    end

    test 'safe hash' do
      audit = FactoryBot.build(:audit, provider_id: provider.id)
      assert_equal expected_hash(audit), audit.send(:to_h_safe)
      audit.save!
      assert_equal expected_hash_persisted(audit), audit.send(:to_h_safe)
    end

    test 'log trail' do
      audit.save!
      assert_equal expected_hash_persisted.to_json, audit.send(:log_trail)
    end

    test 'log trail without user' do
      User.current = nil
      audit = FactoryBot.create(:audit)
      assert_equal expected_hash_persisted(audit).to_json, audit.send(:log_trail)
    end

    test 'obfuscated audit filters sensitive keys' do
      provider_id = provider.id
      audit = FactoryBot.build(:audit, auditable_type: 'Account', auditable_id: 123, provider_id: provider_id, audited_changes: { 'org_name' => 'hello', 'site_access_code' => 'sensitive' })
      audit_obfuscated = audit.obfuscated
      assert_not_equal audit.object_id, audit_obfuscated.object_id
      assert_equal({ 'org_name' => 'hello', 'site_access_code' => 'sensitive' }, audit.audited_changes)
      assert_equal({ 'org_name' => 'hello', 'site_access_code' => '[FILTERED]' }, audit_obfuscated.audited_changes)
    end

    protected

    def expected_hash(audit = @audit)
      provider_id = audit.provider_id
      user = User.current
      {
        auditable_type: 'Account',
        auditable_id: provider_id,
        action: 'create',
        audited_changes: { 'org_name' => 'Some Org Name' },
        version: 1,
        provider_id: provider_id,
        user_id: user&.id,
        user_type: user&.class.to_s.presence,
        request_uuid: audit.request_uuid,
        remote_address: nil,
        created_at: nil,
        user_role: user&.role,
        audit_id: nil
      }.stringify_keys
    end

    def expected_hash_persisted(audit = @audit)
      expected_hash(audit).merge({ created_at: audit.created_at, audit_id: audit.id }.stringify_keys)
    end
  end
end
