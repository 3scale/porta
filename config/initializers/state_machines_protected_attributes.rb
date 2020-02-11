# frozen_string_literal: true
module StateMachines
  module Integrations
    module ActiveRecord
      if defined?(ProtectedAttributes)
        def define_state_initializer
          define_helper :instance, <<-end_eval, __FILE__, __LINE__ + 1
            def initialize(attributes = nil, options = {})
              super(attributes, options) do |*args|
                self.class.state_machines.initialize_states(self, {}, attributes || {})
                yield(*args) if block_given?
              end
            end
          end_eval
        end
      end
    end
  end
end
