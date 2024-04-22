# frozen_string_literal: true

require 'active_job/arguments'

module EventStore
  class Event < RailsEventStoreActiveRecord::Event
    include BackgroundDeletion

    module WithGlobalId
      module_function

      YAML = ActiveRecord::Coders::YAMLColumn.new('EventStore', object_class = Hash)

      class << self
        delegate :serialize, :deserialize, to: 'ActiveJob::Arguments'
      end

      class SerializationEventError < StandardError
        include Bugsnag::MetaData

        def initialize(object:, error:)
          self.bugsnag_meta_data = { object: object.as_json }

          super error
        end
      end

      # we have to wrap it into array, because ActiveJob::Arguments.serialize
      # andActiveJob::Arguments.deserialize work only on arrays and they are
      # the only public exposed api
      def dump(obj)
        YAML.dump serialize([obj]).first
      rescue URI::InvalidURIError, URI::GID::MissingModelIdError => error
        raise SerializationEventError, object: obj, error: error
      end

      def load(str)
        return {} unless str
        deserialize([YAML.load(str)]).first.symbolize_keys
      end
    end

    serialize :data, WithGlobalId
    # Can't really use ActiveJob::Arguments because it does not support Time type
    # and metadata contain timestamp when the event was created
    # https://github.com/rails/rails/issues/18519
    # serialize :metadata, WithGlobalId
    # TODO: review this statement, because the abovementioned issue is fixed
    # in Rails 6.0 by https://github.com/rails/rails/pull/32026

    attr_readonly :provider_id

    validates :provider_id, presence: true
    validates :stream, :event_type, :event_id, length: { maximum: 255 }

    before_validation :provider_id_from_metadata

    belongs_to :account, foreign_key: :provider_id, inverse_of: :events, required: false
    # It is not required because when we delete a provider and all its relationships,
    # we still want the events of the relationships to be saved in order to do the correspondent actions
    # once the provider is deleted (whatever the subscribers tells them to do).

    alias provider account

    TTL = 1.week

    scope :stale, -> { where.has { created_at <= TTL.ago } }

    class EventRollbackError < StandardError
      include Bugsnag::MetaData

      def initialize(error:, event:)
        event_details = event.to_h.as_json
        self.bugsnag_meta_data = { event: event_details }

        super "Error raised trying to roll back #{event}: #{self}, event details: #{event_details}"
        set_backtrace error.backtrace
      end
    end

    # Since Rails 6.1 the EventStore::Event records (among others) are added to the
    # list of the objects, belonging to a current transaction, and #rolledback! is called on them
    # if the transaction is rolled back on the DB.
    # see https://github.com/rails/rails/commit/77f7b2df#diff-8dd03b7fb9b72a3bd338955c1de75652d60453230c6544f3851c0d0b3746a675L345-R349
    # The problem is that this triggers the Event's `load` and `deserialize` (to restore the original state), and if
    # the object referenced in the event via GlobalID does not exist, the deserialization of the event will fail.
    # Prevent an exception during rollback but try to report when that's unsafe.
    def rolledback!(*)
      super
    rescue StandardError => exception
      System::ErrorReporting.report_error EventRollbackError.new(error: exception, event: self) if has_transactional_callbacks?
    end

    def to_h
      %i[id event_type event_id metadata created_at provider_id tenant_id metadata].index_with { |key| send(key) }
    end

    private

    def provider_id_from_metadata
      self.provider_id ||= metadata.try!(:fetch, :provider_id, nil)
    end
  end
end
