require 'test_helper'

class AuditedHacksTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def setup
    @provider = FactoryBot.create(:provider_account)
    Audited.audit_class.delete_all
  end

  def test_user
    User.current = @provider.provider_account.users.first!

    stub_core_change_provider_key(@provider.provider_key)

    Cinstance.with_auditing do
      assert_difference Audited.audit_class.method(:count) do
        Sidekiq::Testing.inline! do
          @provider.bought_cinstance.change_user_key!
        end
      end
    end

    audit = Audited.audit_class.last!
    assert_equal User.current, audit.user
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

    test 'safe hash for create action' do
      assert_equal expected_hash_new_record, audit.send(:to_h_safe)

      audit.save!

      assert_equal expected_hash_persisted, audit.send(:to_h_safe)
    end

    test 'sahe hash for update action' do
      audit = FactoryBot.build(:audit, action: 'update', provider_id: provider.id)
      changed_attributes = { action: 'update', changed_attributes: ['org_name'] }.stringify_keys

      assert_equal expected_hash_new_record(audit).merge(changed_attributes), audit.send(:to_h_safe)

      audit.save!

      assert_equal expected_hash_persisted(audit).merge(changed_attributes), audit.send(:to_h_safe)
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

    protected

    def expected_hash_new_record(audit = @audit)
      provider_id = audit.provider_id
      expected_hash = {
        auditable_type: 'Account',
        auditable_id: provider_id,
        action: 'create',
        version: 1,
        provider_id: provider_id,
        user_id: nil,
        user_type: nil,
        request_uuid: audit.request_uuid,
        remote_address: nil,
        created_at: nil,
        user_role: nil,
        audit_id: nil
      }
      user = User.current
      expected_hash.merge!(user_id: user.id, user_type: 'User', user_role: user.role) if user
      expected_hash.stringify_keys
    end

    def expected_hash_persisted(audit = @audit)
      expected_hash_new_record(audit).merge({ created_at: audit.created_at, audit_id: audit.id }.stringify_keys)
    end
  end
end
