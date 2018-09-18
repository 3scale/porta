class StateMachine::InvalidTransitionRepresenter < ThreeScale::Representer
  wraps_resource :error

  property :from
  property :event
  property :error, getter: ->(*) { machine.errors_for(object) }
  property :object, extend: ->(object, *) { "#{object.class}Representer".constantize }

  class JSON < StateMachine::InvalidTransitionRepresenter
    include Roar::JSON
  end

  class XML < StateMachine::InvalidTransitionRepresenter
    include Roar::XML

    wraps_resource :error
  end
end
