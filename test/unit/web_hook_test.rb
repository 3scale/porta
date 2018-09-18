require 'test_helper'

class WebHookTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  should validate_presence_of :account_id

  def test_switchable_attributes
    WebHook.stubs(:column_names).returns(['alaska'])
    assert_equal [], WebHook.switchable_attributes

    WebHook.stubs(:column_names).returns(['alaska_on'])
    assert_equal ['alaska_on'], WebHook.switchable_attributes
  end

  # could not get it with shoulda :-(
  should "validate uniqueness of account_id" do
    wk1 = WebHook.new :url => "http://foo.example.com"
    wk1.account_id = 1
    wk1.save!
    wk2 = WebHook.new :url => "http://bar.example.com"
    wk2.account_id = 1

    assert ! wk2.valid?
    assert wk2.errors[:account_id].present?
  end

  context 'pushing behaviour' do
    setup do
      stub_backend_get_keys

      @provider = Factory(:provider_account)
      Account.any_instance.stubs(:web_hooks_allowed?).returns(true)

      @service = Factory :simple_service, backend_version: '2', :account => @provider
      app_plan = Factory :simple_application_plan, :issuer => @service
      @app_plan = app_plan
      @wh = WebHook.create!(:account => @provider, :url => 'http://' + @provider.domain,
                            :active => true)

      # no idea how, but buyer from factory comes with strange user
      # user has account association preloaded to nil
      @buyer = Factory(:simple_buyer, :provider_account => @provider)
      @user  = Factory(:simple_user, :account => @buyer)

      @buyer.buy! @provider.account_plans.first
      @application = @buyer.buy! app_plan
    end

    should 'fire webhook' do
      @wh.update_attributes :provider_actions => true,
                            :account_deleted_on => true,
                            :user_deleted_on => false

      User.current = Factory(:simple_user, :account => @provider)
      @buyer.destroy

      job = WebHookWorker.jobs.first

      assert job

      xml =  job['args'][1]['xml']

      assert_equal Hash.from_xml(@buyer.to_xml),
                   Hash.from_xml(xml)['event']['object']

      RestClient.expects(:post).once
      WebHookWorker.drain
    end

    should 'fire webhook on create app' do
      @service.update_column(:backend_version, 2)
      @wh.update_attributes provider_actions: true,
                            account_deleted_on: false,
                            application_created_on: true,
                            application_updated_on: false,
                            application_deleted_on: false,
                            user_deleted_on: false

      User.current = Factory(:simple_user, :account => @provider)

      Cinstance.any_instance.stubs(create_key_after_create?: true)
      application = @buyer.buy!(@app_plan)


      job = WebHookWorker.jobs.first
      hash = Hash.from_xml(job['args'][1]['xml'])
      keys_hash = hash["event"]["object"]["application"]["keys"]
      assert keys_hash.present?
      assert_equal application.keys, keys_hash.values
    end


  end

  test '#ping' do
    hook = WebHook.new :url => "http://foo"

    HTTPClient.stubs(:get).returns(stub(:status => 200))
    assert_equal 200, hook.ping.status

    HTTPClient.stubs(:get).raises(RuntimeError.new('E_NO_POTATOES'))
    assert_equal 'E_NO_POTATOES', hook.ping.message
  end
end
