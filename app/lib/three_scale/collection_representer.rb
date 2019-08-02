# frozen_string_literal: true

require 'roar/json/collection'
require 'representable/hash/collection'

class ThreeScale::CollectionRepresenter < ThreeScale::Representer
  include Representable::Hash::Collection

  module XMLCollection
    extend ActiveSupport::Concern

    included do
      mattr_accessor :xml_collection, instance_writer: false
      self.xml_collection = ThreeScale::Api::Collection
    end

    def to_xml(options = {})
      xml_collection.new(self).to_xml(options.merge(root: representation_wrap))
    end
  end
end
