# frozen_string_literal: true

module Annotating
  extend ActiveSupport::Concern

  class_methods do
    def annotated
      class_eval do
        include Model
        include ManagedBy
      end
    end
  end

  class << self
    def models
      return @models if @models

      # this is to see all models in dev env, otherwise some may not be yet loaded
      Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models") unless Rails.env.production?

      @models = ActiveRecord::Base.descendants.select { |model| model.include?(Model) }
    end
  end
end
