require 'set'

module Liquid
  module Drops
    class Base < Liquid::Drop
      class_attribute :_deprecated_names, :_allowed_names, :instance_writer => false, :instance_reader => false

      extend Liquid::Docs::DSL::Drops

      private

      # This reads the @context variable of Liquid::Drop class, but that class does not
      # provide reader for it for some reason.
      attr_reader :context

      # module proxy will mark all included module methods as private
      class ModuleProxy
        def initialize(base)
          @base = base
        end

        def include(mod)
          @base.all_hidden do
            original_methods = @base.instance_methods
            @base.send(:include, mod)
            defined_methods = @base.instance_methods - original_methods
            privatize(defined_methods)
          end
        end

        def privatize(defined_methods)
          defined_methods.each do |method|
            @base.send(:private, method)
          end
        end

        def publicize(*defined_methods)
          defined_methods.each do |method|
            @base.send(:public, method)
          end
        end

        def proxy(&block)
          instance_eval(&block)
        end
      end

      class << self

        # Use this to include internal helpers in the drops.
        # All included methods will be private.
        #
        def privately_include(&block)
          ModuleProxy.new(self).proxy(&block)
        end

        def wrap object
          if object.respond_to?(:map)
            Drops::Collection.for_drop(self).new(object)
          else
            new object
          end
        end

        def deprecated_name *variables
          if variables.present?
            self._deprecated_names = deprecated_name + variables
          else
            self._deprecated_names or Set.new
          end
        end
        alias deprecated_names deprecated_name

        def allowed_name *variables
          if variables.present?
            self._allowed_names = allowed_name + variables
          else
            self._allowed_names or Set.new
          end
        end
        alias allowed_names allowed_name

        def doc_title
          self.name
        end

        def allowed_name?(var)
          allowed_name.include? var.to_sym
        end

        def deprecated_name?(var)
          deprecated_name.include? var.to_sym
        end

        def deprecated(object)
          Drops::Deprecated.wrap(object)
        end
      end

      privately_include  do
        include System::UrlHelpers.cms_url_helpers
        publicize :_routes
      end


      def url_options
        default_url_options
      end
      public :url_options

      def optimize_routes_generation?
        true
      end
    end
  end
end
