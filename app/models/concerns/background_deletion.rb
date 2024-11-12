# frozen_string_literal: true

module BackgroundDeletion
  extend ActiveSupport::Concern

  included do
    class_attribute :background_deletion, default: [], instance_writer: false
  end

  class Reflection

    DEFAULT_DESTROY_METHOD = 'destroy'
    DEFAULT_HAS_MANY_OPTION = true

    attr_reader :name, :options

    def initialize(association_config)
      config = Array(association_config)

      @name = config[0]
      @options = config[1].presence || {}
    end

    def many?
      options.fetch(:has_many) { DEFAULT_HAS_MANY_OPTION }
    end

    def class_name
      @class_name ||= options[:class_name].presence || name.to_s.singularize.classify
    end

    def klass
      @klass ||= class_name.constantize
    end

    def background_destroy_method
      options[:action].to_s.presence || DEFAULT_DESTROY_METHOD
    end
  end
end
