require 'test_helper'

class WebHook::EventTest < ActiveSupport::TestCase
  def stub_resource(klass = Cinstance)
    resource = klass.new
    root = klass.model_name.singular
    resource.stubs(:to_xml).returns("<#{root}><xml/></#{root}>")
    resource
  end

  def build_provider(webhook_attrs = {})
    provider = Factory.build(:provider_account)
    provider.stubs(:web_hooks_allowed?).returns(true)

    provider.build_web_hook(webhook_attrs.merge(:active => true))
    provider
  end

  test '.enqueue' do
    resource = stub_resource
    provider = build_provider(:application_created_on => true)

    assert_raise(WebHook::Event::MissingResourceError) do
      WebHook::Event.enqueue(nil, nil, {})
    end

    # no provider && webhook
    refute WebHook::Event.enqueue(nil, resource, :event => 'created')

    # no event
    refute WebHook::Event.enqueue(provider, resource)

    resource.class.connection.stubs(transaction_open?: false)
    WebHookWorker.expects(:perform_async).once.returns(true)
    assert WebHook::Event.enqueue(provider, resource, :event => 'created')
  end

  test 'valid event' do
    web_hook = mock('webhook', :enabled? => true)
    provider = mock('provider', :web_hook => web_hook)
    provider.stubs(:web_hooks_allowed?).returns(true)

    resource = stub_resource
    resource.created_at = resource.updated_at = Time.now

    event = WebHook::Event.new(provider, resource)

    assert event.valid?
  end

  test 'disabled webhook' do
    provider = build_provider(:application_created_on => true)
    resource = stub_resource

    event = WebHook::Event.new(provider, resource, :event => 'created')

    assert event.valid?
    provider.stubs(:web_hooks_allowed?).returns(false)
    refute event.valid?

    # because webhook is not active
    provider.web_hook.active = false
    refute event.valid?

    # because event is not enabled
    event = WebHook::Event.new(provider, resource, :event => 'updated')
    provider.web_hook.active = true
    refute event.valid?


  end

  # TODO: check xml of webhook event and compare it to model

  class EnqueueTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    test 'enqueue' do
      account = FactoryGirl.create(:provider_account)

      account.stubs(web_hooks_allowed?: true,
                    web_hook: WebHook.new(active: true, account_created_on: true))

      assert_equal 0, WebHookWorker.jobs.size
      Account.transaction do
        WebHook::Event.enqueue(account, account, event: 'created')
        assert_equal 0, WebHookWorker.jobs.size
      end
      assert_equal 1, WebHookWorker.jobs.size
    end
  end
end
