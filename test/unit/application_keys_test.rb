require 'test_helper'

class ApplicationKeysTest < ActiveSupport::TestCase

  subject { @application_key ||= FactoryBot.create(:application_key) }

  def setup
    ApplicationKey.disable_backend!
    @application = FactoryBot.create(:cinstance)
    @application_keys = @application.application_keys
  end

  def teardown
    ApplicationKey.enable_backend!
  end

  test 'archive_as_deleted' do
    application = FactoryBot.create(:simple_cinstance)

    application_key = FactoryBot.create(:application_key, application: application)
    assert_no_difference(DeletedObject.application_keys.method(:count)) { application_key.destroy! }

    application_key = FactoryBot.create(:application_key, application: application)
    application_key.stubs(destroyed_by_association: true)
    assert_difference(DeletedObject.application_keys.method(:count)) { application_key.destroy! }
    assert_equal application_key.id, DeletedObject.application_keys.last!.object_id
  end

  test 'have immutable value' do
    assert_raise(ActiveRecord::ActiveRecordError) do
      subject.update_attribute :value, 'another'
    end
  end

  test 'add app keys' do
    assert_equal 0, @application_keys.size

    assert @application_keys.add('whatever').persisted?
    # should validate uniqueness
    refute @application_keys.add('whatever').persisted?

    assert_equal 1, @application_keys.size
  end

  test 'remove key' do
    key = FactoryBot.create(:application_key, :application => @application)
    assert_equal [key], @application.application_keys.reload
    assert @application.application_keys.remove(key.value)
    assert_equal [], @application.application_keys
  end

  test 'not remove key if mandatory' do
    key = @application_keys.add('whatever')

    @application.service.mandatory_app_key = true
    refute @application_keys.remove('whatever')
  end

  test 'limit number of keys' do
    ApplicationKey::KEYS_LIMIT.times do |n|
      assert @application_keys.add("app-key-#{n+1}").persisted?
    end

    # KEYS_LIMIT + 1 is over the limit
    # TODO: maybe check for raise?
    application_key = @application_keys.add('limit-reached')
    refute application_key.persisted?

    refute_match(/translation missing/, application_key.errors[:base].to_sentence)
  end

  test 'remove! key if needed' do
    # Adding this to test the correct scope
    cinstance = FactoryBot.create(:cinstance)
    cinstance.application_keys.add 'hello'

    key = @application_keys.add('whatever')

    # this prevents deleting last key
    @application.service.mandatory_app_key = true

    refute @application_keys.remove('whatever')
    assert @application_keys.remove!('whatever')
  end

  test 'return list of values' do
    assert @application_keys.add('some-key')
    assert_equal ['some-key'], @application_keys.pluck_values
  end

  test 'raise when removing unknown value' do
    assert_raise(ActiveRecord::RecordNotFound) do
      @application_keys.remove('unknown')
    end
  end

  test 'notify when scoped with notification' do

    CinstanceMessenger.expects(:key_created)
        .with(@application, 'some-key').returns(stub(:deliver))
    @application_keys.add('some-key')

    CinstanceMessenger.expects(:key_deleted)
        .with(@application, 'some-key').returns(stub(:deliver))
    @application_keys.remove('some-key')
  end

  test 'push webhooks' do
    @application.expects(:push_web_hooks_later).with(:event => 'key_created')
    @application_keys.add('some-key')

    @application.expects(:push_web_hooks_later).with(:event => 'key_deleted')
    @application_keys.remove('some-key')
  end

  test 'does not push webhook when it is destroyed by association' do
    app_key = FactoryBot.create(:application_key)
    app_key.application.expects(:push_web_hooks_later).with(event: 'key_deleted').never
    app_key.destroyed_by_association = true
    app_key.destroy!
  end

  test 'update backend' do
    ApplicationKey.enable_backend!

    expect_backend_create_key(@application, 'some-key')
    @application_keys.add('some-key')

    expect_backend_delete_key(@application, 'some-key')
    @application_keys.remove('some-key')
  end

  test 'skip notifiation without scope' do
    CinstanceMessenger.expects(:key_created).never
    CinstanceMessenger.expects(:key_deleted).never

    NotificationCenter.silent_about(ApplicationKey) do
      @application_keys.add('some-key')
      @application_keys.remove('some-key')
    end
  end

  def test_account_destroy_does_not_send_email
    account = subject.account.reload
    CinstanceMessenger.expects(:key_deleted).never # because we are destroying the account and application. hence destroying by association
    account.destroy!
  end

  def test_destroy_sends_email
    app_key = FactoryBot.create(:application_key)

    cinstante_messenger_key_deleted = CinstanceMessenger.key_deleted(app_key.application, app_key.value)
    CinstanceMessenger.expects(:key_deleted).with(app_key.application, app_key.value).returns(cinstante_messenger_key_deleted).once
    cinstante_messenger_key_deleted.expects(:deliver)

    app_key.destroy!
  end

  def test_destroyed_by_association_does_not_send_email
    CinstanceMessenger.expects(:key_deleted).never

    app_key = FactoryBot.create(:application_key)
    app_key.stubs(destroyed_by_association: true)
    app_key.destroy!
  end

  def test_format
    key = ApplicationKey.new(application: Cinstance.new(service: Service.new))

    key.value = 'foo123'
    assert key.valid?, key.errors.full_messages.to_sentence

    key.value = 'foo-123'
    assert key.valid?, key.errors.full_messages.to_sentence

    key.value = 'foo_123'
    assert key.valid?, key.errors.full_messages.to_sentence
  end

  def test_regenerate_key
    @application_keys.add(key = 'app-key')
    @application.reload
    expected_updated_at = @application.updated_at + 2.hours

    Timecop.travel(2.hours.from_now) do
      @application_keys.regenerate(key)
    end
    assert_in_delta expected_updated_at, @application.updated_at, 1.second

  end

  test 'Value can include special characters as defined in the RFC 6749' do
    generate_random_key_with_all_chars_of_rfc_6749 = -> { ("\x20".."\x7e").to_a.shuffle.join }
    app_key = FactoryBot.build(:application_key, value: (value = generate_random_key_with_all_chars_of_rfc_6749.call))

    assert app_key.save
    assert value, app_key.reload.value
  end

  test 'is audited' do
    app_key = FactoryBot.build(:application_key)

    assert_difference(Audited.audit_class.method(:count)) do
      ApplicationKey.with_synchronous_auditing do
        app_key.save!
      end
    end

    assert_app_key_audit_data(app_key, Audited.audit_class.last!)

    assert_difference(Audited.audit_class.method(:count)) do
      ApplicationKey.with_synchronous_auditing do
        app_key.destroy!
      end
    end

    assert_app_key_audit_data(app_key, Audited.audit_class.last!)
  end

  def assert_app_key_audit_data(app_key, audit)
    assert_equal app_key.account.provider_account.id, audit.provider_id
    assert_equal app_key.class.name, audit.kind
    expected_audited_changes = {
      'application_id' => app_key.application.id,
      'created_at' => app_key.created_at.utc
    }
    assert_equal expected_audited_changes, audit.audited_changes
  end

end
