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
      # class User < ApplicationRecord
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

        mod = Module.new
        names.each do |name|
          options_for_lazy_initialization[name] = options

          mod.define_method("#{name}") do
            super() || lazily_initialize(name)
          end
        end

        prepend mod
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
