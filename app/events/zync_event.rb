# frozen_string_literal: true

class ZyncEvent < RailsEventStore::Event

  # Create Zync Event

  def self.create(event, model = event)
    metadata = event.metadata
    provider_id = metadata.fetch(:provider_id) { model.tenant_id }

    attributes = {
      type: type_for(model),
      id: model.id,
      parent_event_id: event.event_id,
      parent_event_type: event.class.name,
      tenant_id: provider_id,
    }.merge(metadata.fetch(:zync, {}))

    new(
      metadata: {
        provider_id: provider_id,
      },
      **attributes
    )
  end

  def record
    @_record ||= model.find(id)
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

  def self.type_for(model)
    case model
    when Cinstance, ApplicationRelatedEvent then 'Application'
    else model.model_name.name
    end
  end
end
