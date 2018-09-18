module ThreeScale
  module LazyInitialization

    extend ActiveSupport::Concern

    included do
      cattr_accessor :options_for_lazy_initialization
      self.options_for_lazy_initialization = {}
    end

    module ClassMethods
      # Specify associations that should be initialized lazily (on first access).
      #
      # == Example
      #
      # class User < ActiveRecord::Base
      #   has_one :settings
      #   lazy_initialization_for :settings
      # end
      #
      # You can specify more than one associations:
      #
      #   lazy_initialization_for :settings, :profile, :avatar
      #
      # Curretly only has_one and belongs_to are supported.
      #
      # If the :if option is set to a name of a method, the association will be initialized
      # only if the method returns true:
      #
      #   lazy_initialization_for :avatar, :if => :avatar_allowed?
      #
      def lazy_initialization_for(*names)
        options = names.extract_options!

        names.each do |name|
          options_for_lazy_initialization[name] = options

          define_method("#{name}_with_lazy_initialization") do
            send("#{name}_without_lazy_initialization") || lazily_initialize(name)
          end

          alias_method_chain name, :lazy_initialization
        end
      end
    end

    private

    def lazily_initialize(name)
      options = options_for_lazy_initialization[name] || {}

      if !options.has_key?(:if) || send(options[:if])
        if new_record? || ActiveRecord::Base.connection.read_only_transaction?
          send("build_#{name}")
        else
          send("create_#{name}")
        end
      end
    end
  end
end
