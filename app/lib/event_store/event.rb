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
        deserialize([YAML.load(str)]).first.symbolize_keys
      end
    end

    serialize :data, WithGlobalId
    # Can't really use ActiveJob::Arguments because it does not support Time type
    # and metadata contain timestamp when the event was created
    # https://github.com/rails/rails/issues/18519
    # serialize :metadata, WithGlobalId

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

    private

    def provider_id_from_metadata
      self.provider_id ||= metadata.try!(:fetch, :provider_id, nil)
    end
  end
end
