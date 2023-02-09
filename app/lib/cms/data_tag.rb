# frozen_string_literal: true

module CMS::DataTag
  extend ActiveSupport::Concern

  included do
    class_attribute :data_tag
  end

  module ClassMethods
    def has_data_tag(tag_name)
      self.data_tag = tag_name
    end
  end
end
