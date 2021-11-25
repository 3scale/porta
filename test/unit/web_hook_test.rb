# frozen_string_literal: true

require 'test_helper'

class WebHookTest < ActiveSupport::TestCase
  should validate_presence_of :account_id
  should validate_uniqueness_of :account_id

  def test_switchable_attributes
    WebHook.stubs(:column_names).returns(['alaska'])
    assert_equal [], WebHook.switchable_attributes

    WebHook.stubs(:column_names).returns(['alaska_on'])
    assert_equal ['alaska_on'], WebHook.switchable_attributes
  end

  class PushingBehaviourTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    setup do
      stub_backend_get_keys

      @provider = FactoryBot.create(:provider_account)
      Account.any_instance.stubs(:web_hooks_allowed?).returns(true)

      @service = FactoryBot.create(:simple_service, backend_version: '2', account: @provider)
      @app_plan = FactoryBot.create(:simple_application_plan, issuer: @service)

      @wh = WebHook.create!(account: @provider, url: "http://#{@provider.domain}", active: true)

      @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
    end

    test 'fire webhook' do
      @wh.update provider_actions: true,
                 account_deleted_on: true,
                 user_deleted_on: false

      User.current = FactoryBot.create(:simple_user, account: @provider)
      @buyer.destroy

      assert job = WebHookWorker.jobs.first

      xml = job.dig('args', 1, 'xml')

      assert_equal Hash.from_xml(@buyer.to_xml),
                   Hash.from_xml(xml).dig('event', 'object')

      RestClient.expects(:post).once
      WebHookWorker.drain
    end

    test 'fire webhook on create app' do
      @wh.update provider_actions: true,
                 account_deleted_on: false,
                 application_created_on: true,
                 application_updated_on: false,
                 application_deleted_on: false,
                 user_deleted_on: false

      User.current = FactoryBot.create(:simple_user, account: @provider)

      Cinstance.any_instance.stubs(create_key_after_create?: true)
      application = @buyer.buy!(@app_plan)

      job = WebHookWorker.jobs.first
      hash = Hash.from_xml(job.dig('args', 1, 'xml'))
      keys_hash = hash.dig("event", "object", "application", "keys")
      assert keys_hash.present?
      assert_equal application.keys, keys_hash.values
    end
  end

  test '#ping' do
    hook = WebHook.new(url: "http://foo")

    HTTPClient.stubs(:get).returns(stub(status: 200))
    assert_equal 200, hook.ping.status

    HTTPClient.stubs(:get).raises(RuntimeError.new('E_NO_POTATOES'))
    assert_equal 'E_NO_POTATOES', hook.ping.message
  end
end
