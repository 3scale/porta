# frozen_string_literal: true

class ZyncEvent < BaseEventStoreEvent

  # Create Zync Event

  def self.create(parent_event, model = parent_event, metadata: {})
    parent_metadata = parent_event.metadata
    provider_id = parent_metadata.fetch(:provider_id) { model.tenant_id }

    attributes = {
      type: type_for(model),
      id: model.id,
      parent_event_id: parent_event.event_id,
      parent_event_type: parent_event.class.name,
      tenant_id: provider_id,
    }.merge(parent_metadata.fetch(:zync, {}))

    new(
      metadata: {
        provider_id: provider_id,
      }.merge(metadata),
      **attributes
    )
  end

  def record
    @_record ||= model.find_by(id: id) || model.new(id: id)
  end

  def model
    case type
    when 'Application' then Cinstance
    else type.constantize
    end
  end

  NONE = [].freeze
  private_constant :NONE

  def dependencies
    return non_persisted_dependencies unless record.persisted?
    case record
    when Cinstance
      [ service = record.service, service.proxy ]
    when Proxy
      [ record.service ]
    when Service
      NONE
    else
      NONE
    end
  end

  def skip_background_sync?
    metadata[:skip_background_sync]
  end

  def self.type_for(model)
    case model
    when Cinstance, ApplicationRelatedEvent then 'Application'
    else model.model_name.name
    end
  end

  private

  def non_persisted_dependencies
    case record
    when Proxy, Cinstance
      [Service.new({id: data[:service_id]}, without_protection: true)]
    else
      NONE
    end
  end
end
