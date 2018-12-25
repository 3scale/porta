# frozen_string_literal: true

require 'test_helper'

class WebHookWorkerTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  setup do
    User.current = nil
    @worker = WebHookWorker.new
  end

  teardown do
    User.current = nil
  end

  test 'heandled errors' do
    assert_same_elements [SocketError, RestClient::Exception, Errno::ECONNREFUSED, Errno::ECONNRESET],  WebHookWorker::HANDLED_ERRORS
  end

  test 'webhook job performs work' do
    webhook = FactoryBot.create(:webhook, :account_created_on => true, :user_created_on => true)
    Account.any_instance.stubs(:web_hooks_allowed?).returns(true)
    User.current = webhook.account.users.first

    jobs = WebHookWorker.jobs
    assert jobs.empty?
    FactoryBot.create(:buyer_account, :provider_account => webhook.account)
    assert_equal 2, jobs.size
  end

  test 'be retried' do
    assert WebHookWorker.get_sidekiq_options['retry']
    WebHookWorker.ancestors.include?(ThreeScale::SidekiqRetrySupport::Worker)
  end

  class CustomError < StandardError; end

  test 'handles failure when last retry' do
    exception = CustomError.new
    job = { 'args' => ['some-uuid', { 'provider_id' => 'provider_id', 'url' => 'url', 'xml' => 'xml', 'content_type' => 'content_type' }] }
    WebHookFailures.expects(:add).with('provider_id', exception, 'some-uuid', 'url', 'xml')
    WebHookWorker.sidekiq_retries_exhausted_block.call(job, exception)
  end

  test 'perform sends the webhook' do
    @worker.expects(:push).with(url: 'url', xml: 'xml', content_type: 'content_type')
    @worker.perform('uuid', { 'provider_id' => 'provider', 'url' => 'url', 'xml' => 'xml', 'content_type' => 'content_type' })
  end

  test 're-raises errors generated by the remote' do
    WebHookWorker::HANDLED_ERRORS.each do |error_class|
      RestClient.expects(:post).with('url', 'xml', content_type: 'content_type').raises(error_class)
      assert_raise(::WebHookWorker::ClientError) do
        @worker.push(url: 'url', xml: 'xml', content_type: 'content_type')
      end
    end
  end

  test 'push with content type' do
    RestClient.expects(:post).with('url', 'xml', content_type: 'application/xml')
    @worker.push(url: 'url', xml: 'xml', content_type: 'application/xml')
  end

  test 'push without content type' do
    RestClient.expects(:post).with('url', params: { xml: 'xml' })
    @worker.push(url: 'url', xml: 'xml')
  end
end
