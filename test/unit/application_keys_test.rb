require 'test_helper'

class ApplicationKeysTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  subject { @application_key ||= FactoryBot.create(:application_key) }

  def setup
    ApplicationKey.disable_backend!
    @application = FactoryBot.create(:cinstance)
    @application_keys = @application.application_keys
  end

  def teardown
    ApplicationKey.enable_backend!
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
    assert_equal [key], @application.application_keys(true)
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

  test 'delete keys when app is deleted' do
    @application_keys.add('some-key')

    ApplicationKey.enable_backend!

    @application.reload

    @application.expects(:web_hook_human_event).with(:event => 'deleted')
    @application.expects(:web_hook_human_event).with(:event => 'key_deleted')
    expect_backend_delete_key(@application, 'some-key')

    @application.destroy
  end


  def test_account_destroy_does_not_send_email
    account = subject.account.reload
    CinstanceMessenger.expects(:key_deleted).never # because we are destroying the account and application
    account.destroy
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
    updated_at = @application.updated_at
    @application_keys.regenerate(key)
    # @application.reload
    assert_not_equal updated_at, @application.updated_at

  end

end
