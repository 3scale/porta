# frozen_string_literal: true

class ZyncEvent < BaseEventStoreEvent

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

  def create_dependencies
    dependencies.map { |dependency| ZyncEvent.create(self, dependency) }
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
