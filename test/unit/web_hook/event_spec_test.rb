require 'minitest_helper'

# TODO: one day, partialy load rails and leave this on autoloader
require 'app/models/web_hook/event'
require 'active_model'
require 'nokogiri'

describe WebHook::Event do
  class ResourceModel
    extend ActiveModel::Naming
    include ActiveModel::AttributeMethods

    attr_accessor :id, :web_hook, :created_at, :updated_at, :destroyed
    alias destroyed? destroyed

    def initialize(attrs = {})
      attrs.each do |key, val|
        send("#{key}=", val)
      end
    end

    def created=(val)
      @created_at = @updated_at = val
    end

    def to_xml(options = {})
      builder = options[:builder]
      builder.resource do |xml|
        xml.xml
      end
    end
  end

  def mock_resource(options = {})
    stub_everything('resource', options.merge(:class => ResourceModel))
  end

  let(:web_hook) { stub_everything('web_hook', :enabled? => true) }
  let(:provider) { stub_everything('provider', :id => 16, :web_hook => web_hook, :provider? => true, :web_hooks_allowed? => true) }
  let(:options)  { Hash.new }

  let(:event)    { WebHook::Event.new(provider, resource, options) }
  let(:enqueue)  { WebHook::Event.enqueue(provider, resource, options) }

  before { WebHook.stubs(:sanitized_url).returns('http://127.0.0.1/') }

  describe "valid event" do
    let(:resource) { ResourceModel.new(:id => 16, :created => Time.now) }

    it { event.must_be :valid? }

    it "enqueues to sidekiq" do
      WebHookWorker.expects(:perform_async).returns(true).with do |webhook_id, options|
        options[:provider_id].must_equal 16
        options[:url].must_equal 'http://127.0.0.1/'
        options[:content_type].must_equal event.content_type
        options[:xml].must_equal event.to_xml

        true
      end

      assert event.enqueue_now
    end

    it "sets xml content type" do
      web_hook.stubs(:push_application_content_type).returns(false)
      event.content_type.must_be_nil

      web_hook.stubs(:push_application_content_type).returns(true)
      event.content_type.must_equal 'application/xml'
    end

    it "is not valid when webhook is disabled" do
      event.must_be :valid?
      web_hook.stubs(:enabled?).returns(false)
      event.wont_be :valid?
    end

    describe "to_xml" do
      let(:xml) { Nokogiri::XML::Document.parse(event.to_xml) }

      it "should have event" do
        xml.xpath('/event/action').text.must_equal 'created'
        xml.xpath('/event/type').text.must_equal 'resource_model'
        xml.xpath('/event/object/resource').must_be :present?
      end
    end

    context 'without transaction' do
      before { WebHookWorker.clear }

      it 'enqueues after commit' do
        assert_equal 0, WebHookWorker.jobs.size
        Account.transaction do
          event.enqueue
          assert_equal 0, WebHookWorker.jobs.size
        end
        assert_equal 1, WebHookWorker.jobs.size
      end

      it 'not enqueues after rollback' do
        assert_equal 0, WebHookWorker.jobs.size
        Account.transaction do
          event.enqueue

          raise ActiveRecord::Rollback
        end
        assert_equal 0, WebHookWorker.jobs.size
      end
    end
  end

  describe "real resource" do
    let(:resource) { ResourceModel.new }

    it { event.resource_type.must_equal 'resource_model' }
    it { event.wont_be :valid? }
    it { refute event.push_event? }

    it { refute enqueue }
  end

  describe "destroyed resource" do
    let(:resource) { mock_resource(:destroyed? => true) }

    it { event.event.must_equal 'deleted' }
    it { event.must_be :valid? }

    it { assert enqueue }
  end

  describe "created resource" do
    let(:now) { Time.now }
    let(:resource) { mock_resource(:created_at => now, :updated_at => now) }

    it { event.event.must_equal 'created' }
    it { event.must_be :valid? }
    it { assert enqueue }
  end

  describe "nil resource" do
    let(:resource) { nil }

    it { proc{ event }.must_raise(WebHook::Event::MissingResourceError) }
    it { proc{ enqueue }.must_raise(WebHook::Event::MissingResourceError) }
  end

  describe "new resource" do
    let(:resource) { mock_resource }

    it { event.event.must_be :nil? }
    it { event.wont_be :valid? }
    it { refute enqueue }
  end

  describe "push_user?" do

    let(:options)  { Hash[:user => user, :event => 'valid'] }
    let(:user)     { stub_everything('user', :account => account) }
    let(:resource) { mock_resource(:provider_account => provider) }

    let(:account)  { stub_everything('account', :buyer? => true, :provider_account => provider) }

    # it is circular reference
    before { web_hook.stubs(:provider).returns(provider) }

    describe "user has right provider" do
      it { event.must_be :push_user? }
      it { event.must_be :enabled? }
      it { event.must_be :valid? }
    end

    describe "user has different provider" do
      let(:account) { stub_everything('account', :buyer? => true) }
      it { event.wont_be :push_user? }
      it { event.wont_be :valid? }
    end

    describe "resource has different provider" do
      let(:resource) { mock_resource }
      it { event.wont_be :push_user? }
      it { event.wont_be :valid? }
    end

  end
end
