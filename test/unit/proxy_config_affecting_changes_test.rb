# frozen_string_literal: true

require 'test_helper'

class ProxyConfigAffectingChangesTest < ActiveSupport::TestCase
  class Model < ActiveRecord::Base
    self.table_name = 'backend_apis'

    def self.column_names
      %w[id name system_name description created_at updated_at]
    end

    include ProxyConfigAffectingChanges::ModelExtension
  end

  def self.build_tracker
    Thread.current[ProxyConfigAffectingChanges::TRACKER_NAME] = ProxyConfigAffectingChanges::Tracker.new
  end

  test 'tracks columns by default' do
    assert_equal %w[name system_name description], Model.proxy_config_affecting_attributes
  end

  test 'allows to set strict list of columns to track' do
    klass = Class.new(Model) do
      define_proxy_config_affecting_attributes :description
    end

    assert_equal %w[description], klass.proxy_config_affecting_attributes
  end

  test 'allows to add exceptions' do
    klass = Class.new(Model) do
      define_proxy_config_affecting_attributes except: :system_name
    end

    assert_equal %w[name description], klass.proxy_config_affecting_attributes
  end

  test 'snapshot of proxy config affecting state' do
    attributes = { name: 'foo', system_name: 'bar', description: 'this is my proxy config affecting model', created_at: Time.now, updated_at: Time.now }
    model = Model.new(attributes)
    assert_equal attributes.slice(*%i[name system_name description]).to_json, model.proxy_config_affecting_state
  end

  test 'tracks proxy config affecting changes on attribute write' do
    within_thread do
      tracker = ProxyConfigAffectingChangesTest.build_tracker
      CheapTrick = Class.new(Model)
      tracker.expects(:track).with(instance_of(CheapTrick)).at_least_once
      CheapTrick.new(name: 'foo', system_name: 'bar', description: 'this is my proxy config affecting model', created_at: Time.now, updated_at: Time.now)
    end
  end

  test 'tracks proxy config affecting changes on attribute update' do
    CheapTrick = Class.new(Model)
    object = CheapTrick.new(name: 'foo', system_name: 'bar', description: 'this is my proxy config affecting model', created_at: Time.now, updated_at: Time.now)
    with_proxy_config_affecting_changes_tracker do |tracker|
      tracker.expects(:track).with(instance_of(CheapTrick)).at_least_once
      object[:system_name] = "newname"
    end
  end

  test 'tracks proxy config affecting changes on column update' do
    CheapTrick = Class.new(Model)
    object = CheapTrick.create(name: 'foo', system_name: 'bar', description: 'this is my proxy config affecting model', created_at: Time.now, updated_at: Time.now)
    with_proxy_config_affecting_changes_tracker do |tracker|
      tracker.expects(:track).with(instance_of(CheapTrick)).at_least_once
      object.update_column(:system_name, "newname")
    end
  end

  test 'does no track proxy config affecting changes on untracked attributes' do
    CheapTrick = Class.new(Model)
    object = CheapTrick.new(name: 'foo', system_name: 'bar', description: 'this is my proxy config affecting model', created_at: Time.now, updated_at: Time.now)
    with_proxy_config_affecting_changes_tracker do |tracker|
      tracker.expects(:track).with(instance_of(CheapTrick)).never
      object[:state] = "deleted"
    end
  end

  test 'tracks proxy config affecting changes on destroy' do
    within_thread do
      tracker = ProxyConfigAffectingChangesTest.build_tracker
      CheapTrick = Class.new(Model)
      model = CheapTrick.new(name: 'foo', system_name: 'bar', description: 'this is my proxy config affecting model', created_at: Time.now, updated_at: Time.now)
      tracker.expects(:track).with(instance_of(CheapTrick))
      model.destroy
    end
  end

  class StoredModelTest < ActiveSupport::TestCase
    class StoredModel < ActiveRecord::Base
      include ProxyConfigAffectingChanges::ModelExtension
      define_proxy_config_affecting_attributes :settings
      self.table_name = 'gateway_configurations'

      store :settings, accessors: %i[jwt_claim_with_client_id jwt_claim_with_client_id_type], coder: JSON
    end

    test 'tracks proxy config affecting changes on attribute write' do
      within_thread do
        tracker = ProxyConfigAffectingChangesTest.build_tracker
        CheapTrick = Class.new(StoredModel)
        tracker.expects(:track).with(instance_of(CheapTrick)).at_least_once
        CheapTrick.new(jwt_claim_with_client_id: 'azp', jwt_claim_with_client_id_type: 'plain')
      end
    end

    test 'tracks proxy config affecting changes on destroy' do
      within_thread do
        tracker = ProxyConfigAffectingChangesTest.build_tracker
        CheapTrick = Class.new(StoredModel)
        model = CheapTrick.new(jwt_claim_with_client_id: 'azp', jwt_claim_with_client_id_type: 'plain')
        tracker.expects(:track).with(instance_of(CheapTrick))
        model.destroy
      end
    end

  end

  class TrackerTest < ActiveSupport::TestCase
    setup do
      @tracker = ProxyConfigAffectingChanges::Tracker.new
      @proxy = FactoryBot.create(:simple_proxy)
    end

    attr_reader :tracker, :proxy

    test 'tracks an object' do
      tracker.track(proxy)
      proxy.update_attribute(:endpoint, 'http://new-endpoint.test')
      tracker.expects(:issue_proxy_affecting_change_event).with(proxy)
      tracker.flush
    end

    test 'does not track the same object twice' do
      tracker.track(proxy)
      assert_equal 1, tracker.instance_variable_get(:@tracked_objects).count
      tracker.track(proxy)
      assert_equal 1, tracker.instance_variable_get(:@tracked_objects).count
    end

    test 'lists objects with affecting changes' do
      object_2 = FactoryBot.create(:simple_proxy)
      object_3 = FactoryBot.create(:proxy_rule)

      [proxy, object_2, object_3].each(&tracker.method(:track))

      proxy.update_attribute(:endpoint, 'http://new-endpoint.test')

      assert_equal [proxy], tracker.objects_with_affecting_changes.map(&:object)

      object_3.update_attribute(:pattern, '/other')

      assert_equal [proxy, object_3], tracker.objects_with_affecting_changes.map(&:object)
    end

    test 'flushes all tracked objects with changes' do
      object_2 = FactoryBot.create(:simple_proxy)
      object_3 = FactoryBot.create(:proxy_rule)

      [proxy, object_2, object_3].each(&tracker.method(:track))

      proxy.update_attribute(:endpoint, 'http://new-endpoint.test')
      object_3.update_attribute(:pattern, '/other')

      tracker.expects(:issue_proxy_affecting_change_event).with(proxy).once
      tracker.expects(:issue_proxy_affecting_change_event).with(object_2).never
      tracker.expects(:issue_proxy_affecting_change_event).with(object_3.owner).once

      tracker.flush
    end

    test '#issue_proxy_affecting_change_event' do
      proxy = mock(service: FactoryBot.build_stubbed(:simple_service))
      ProxyConfigs::AffectingObjectChangedEvent.expects(:create_and_publish!).with(proxy, tracker)
      tracker.send(:issue_proxy_affecting_change_event, proxy)
    end
  end
end
