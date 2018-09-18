module Liquid
  module Drops
    # Holds collection of drops.
    # Behaves like array with following extensions:
    #  * delegates class methods allowed_name? and deprecated_name? to wrapped class
    #  * class method ::name returns for example "Collection (Account)"

    class Collection < Array
      extend Drops::Wrapper

      def initialize(array)
        array = array.map do |el|
          drop_class = if self.class.drop
                         # custom class for just one type
                         self.class.drop
                       else
                         # generic collection (i.e. for different plans)
                         "::Liquid::Drops::#{el.class}".constantize
                       end
          drop_class.new(*el)
        end
        super(array)
      end

      def [](key)
        find { |o| o.respond_to?(:system_name) && o.system_name == key } || super
      end

      def has_key?(key)
        any? { |o| o.respond_to?(:system_name) && o.system_name == key }
      end


      def self.name
        if drop
          "Collection (#{drop.name.split('::').last})"
        else
          'Collection'
        end
      end

      def self.allowed_name?(*args)
        if drop
          drop.allowed_name?(*args)
        else
          true
        end
      end

      def self.deprecated_name?(*args)
        if drop
          drop.deprecated_name?(*args)
        else
          false
        end
      end
    end
  end
end
