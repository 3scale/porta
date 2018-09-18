module Liquid
  module Drops

    # Used to wrap drops assigned to liquid variables with wrong name.
    #
    # Purpose:
    #
    # Usage of deprecated variables in liquid temlates will fire
    # Airbrake warning in production of raise an exception in development/test
    # environment.
    #
    # Example:
    #
    #  # will be wrapped as the variable name should be :application
    #  assign_drops :cinstance => Liquid::Drops::Application.new(@cinstance)
    #
    # Implementation:
    #
    # Similar to Ruby 1.9 BasicObject, but delegates almost all method calls to wrapped drop.
    # Some are delegated directly (respond_to?, inspect, is_a?, nil?)
    # for others a method_missing hook is used which also triggers the
    # deprecation warning.
    #
    class Deprecated

      # undef all methods, so it behaves like BasicObject (almost)
      KEEP_METHODS = %w{__id__ __send__ instance_eval == equal? initialize delegate class object_id}.map(&:to_sym)
      ((private_instance_methods + instance_methods).map(&:to_sym) - KEEP_METHODS).each{|m| undef_method(m) }

      extend Liquid::Drops::Wrapper

      delegate :respond_to?, :inspect, :is_a?, :context, :context=, :has_key?, :nil?, :to => :@drop


      class DeprecationError < StandardError
        def initialize(object, method, *args)
          method = args.shift if method == :[]
          super("Called deprecated method #{method}(#{args.join(", ")}) on #{object}")
        end

        def set_backtrace= trace
          @backtrace = trace
        end

        attr_reader :backtrace
      end

      def initialize(drop)
        @drop = drop
      end

      def to_liquid
        self
      end

      def method_missing(method, *args, &block)
        if respond_to?(method)

          exception = DeprecationError.new @drop, method, args
          exception.set_backtrace = ::Kernel.caller(1)

          if notify?
            System::ErrorReporting.report_error(exception, :parameters => {:drop => @drop})
          else
            ::Kernel.raise exception
          end

          @drop.send(method, *args, &block)
        else
          @drop.send(:method_missing, method, *args, &block)
        end
      end

      def notify?
        env = Rails.env
        env.enterprise? or env.production? or env.preview?
      end

      class << self

        def respond_to?(method, *args)
          if [:name, :wrap, :allowed_name?].include?(method)
            super
          else
            drop.try(:respond_to?, method, *args) && super
          end
        end

        def name
          "Deprecated (#{drop.name})"
        end

        def wrap drop
          for_drop(drop.class).new(drop)
        end

        def allowed_name?(name)
          true
        end
      end
    end
  end
end
