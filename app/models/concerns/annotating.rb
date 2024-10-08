# frozen_string_literal: true

module Annotating
  extend ActiveSupport::Concern

  class_methods do
    def annotated
      class_eval do
        include Model
        include ManagedBy

        background_deletion << :annotations
      end
    end
  end

  class << self
    def models
      return @models if @models

      # This is to see all models when creating the DB trigger, otherwise the resulting trigger could be incorrect
      # https://github.com/3scale/porta/pull/3857#discussion_r1707235658
      Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models")

      @models = ActiveRecord::Base.descendants.select { |model| model.include?(Model) }
    end
  end
end
