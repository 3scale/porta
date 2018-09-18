module Liquid
  module Drops
    # this module allows to wrap a class
    # with new one which responds to #drop
    # and delegate help method to it
    #
    # Example:
    #
    #   Liquid::Drops::Base::Collection.for_drop(Liquid::Drops::Account).wrap([account, account])
    #
    #   wraps each object of collection in Account drop and returns Collection
    #   and: collection.class.drop == Liquid::Drops::Account
    #
    # This is done because drop's class holds allowed and deprecated names attributes.

    module Wrapper
      delegate :help, :to => :drop, :allow_nil => true

      def for_drop(drop)
        Class.new(self) do
          @drop = drop
        end
      end

      def drop
        @drop
      end
    end
  end
end
