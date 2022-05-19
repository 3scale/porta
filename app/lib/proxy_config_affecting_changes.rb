# frozen_string_literal: true

module ProxyConfigAffectingChanges
  class TrackedObject
    def initialize(object)
      @object = object
      @initial_state = object.proxy_config_affecting_state.hash
      @new_record = object.new_record?
      @proxies = find_proxies(object)
    end

    attr_reader :object, :initial_state, :new_record

    def ==(other)
      object == other.object
    end

    delegate :destroyed?, :persisted?, to: :object

    def created?
      new_record && persisted?
    end

    def state_changed?
      initial_state != object.reload.proxy_config_affecting_state.hash
    rescue ActiveRecord::RecordNotFound
      !new_record # Cannot find the model. If the object was a new record, then it was not persisted; otherwise, it was destroyed.
    end

    def changed?
      destroyed? || created? || state_changed?
    end

    def proxies
      @proxies.presence || find_proxies
    end

    protected

    def find_object
      object.class.find_by(id: object.id)
    end

    def find_proxies(model = find_object)
      proxy_or_proxies = model.try(:proxy) || model.try(:proxies)
      [*proxy_or_proxies].flatten.compact
    end
  end

  class Tracker
    def initialize
      @tracked_objects = []
    end

    def track(object)
      tracked_object = TrackedObject.new(object)
      return if tracking?(tracked_object)
      @tracked_objects << tracked_object
    end

    def tracking?(tracked_object)
      @tracked_objects.include?(tracked_object)
    end

    def objects_with_affecting_changes
      @tracked_objects.select(&:changed?)
    end

    def flush
      proxies = objects_with_affecting_changes.map(&:proxies).flatten.uniq
      proxies.each(&method(:issue_proxy_affecting_change_event))
    ensure
      @tracked_objects.clear
    end

    # FIXME: This is only so ProxyConfigs::AffectingObjectChangedEvent does not crash
    def id
      Thread.current.name
    end

    protected

    def issue_proxy_affecting_change_event(proxy)
      # Sometimes invoked in the context of or concurrently to a hierarchy deletion,
      # hence the proxy, the service or the account may no longer be available
      return unless proxy&.service&.account

      ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy, self)
    end
  end

  TRACKER_NAME = 'proxy_affecting_changes_tracker'

  module ModelExtension
    extend ActiveSupport::Concern

    included do
      class_attribute :_proxy_config_affecting_attributes, default: [], instance_accessor: false
      class_attribute :_proxy_config_affecting_attributes_exceptions, default: [], instance_accessor: false

      class << self
        def define_proxy_config_affecting_attributes(*attrs, except: [])
          self._proxy_config_affecting_attributes = [*attrs.presence].map(&:to_s)
          self._proxy_config_affecting_attributes_exceptions = [*except].map(&:to_s)
        end

        def proxy_config_affecting_attributes
          tracked_attributes = _proxy_config_affecting_attributes.presence || column_names
          exceptions = (_proxy_config_affecting_attributes_exceptions.presence || []) + %w[id tenant_id created_at updated_at]
          tracked_attributes - exceptions
        end
      end

      delegate :proxy_config_affecting_attributes, to: 'self.class'

      def proxy_config_affecting_state
        attributes.slice(*proxy_config_affecting_attributes).to_json
      end

      def destroy
        track_proxy_affecting_changes
        super
      end

      protected

      def _write_attribute(attr_name, value)
        track_proxy_affecting_changes if proxy_config_affecting_attributes.include?(attr_name.to_s)
        super
      end

      def write_attribute_without_type_cast(attr_name, value)
        track_proxy_affecting_changes if proxy_config_affecting_attributes.include?(attr_name.to_s)
        super
      end

      def write_store_attribute(store_attribute, key, value)
        track_proxy_affecting_changes if proxy_config_affecting_attributes.include?(store_attribute.to_s)
        super
      end

      def track_proxy_affecting_changes
        Thread.current[TRACKER_NAME]&.track(self)
      end
    end
  end

  module ControllerExtension
    extend ActiveSupport::Concern

    included do
      prepend_before_action :track_proxy_affecting_changes
      after_action :flush_proxy_affecting_changes

      protected

      def track_proxy_affecting_changes
        Thread.current[TRACKER_NAME] ||= Tracker.new
      end

      def flush_proxy_affecting_changes
        Thread.current[TRACKER_NAME].flush
      end
    end
  end
end
