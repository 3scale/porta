module Liquid
  module Docs
    module Registration

      # This is used by Liquid::Filters and Liquid::Tags
      # because both has to register self to Liquid::Template
      #
      # We track all registered filters and tags like this
      # so we can collect documentation from them.
      #
      # Example:
      #
      # module Liquid::Filters
      #   extend Liquid::Docs::Registration
      #
      #   def register(klass, template)
      #     template.register_filter(klass)
      #   end
      # end
      #
      # module Liquid::Filters::TrackingCode
      # end
      #
      # Liquid::Filters.register(Liquid::Filters:TrackingCode)
      # Liquid::Filters.register(Liquid::Filters:RailsHelpers)
      #
      # Liquid::Filters.registered
      # # => [ Liquid::Filters::Base, Liquid::Filters:RailsHelpers ]

      attr_accessor :registered

      def self.extended(base)
        base.registered = {}
      end

      def register(klass, template)
        name = klass.name
        registered[name] = klass
        super if defined?(super)
      end

      def documentation
        Liquid::Docs::Generator[ registered.map{|name, klass| [klass, klass.documentation]} ]
      end

    end
  end
end
