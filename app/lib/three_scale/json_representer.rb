# frozen_string_literal: true

require 'roar/json'
require 'roar/hypermedia'

module ThreeScale::JSONRepresenter
  extend ActiveSupport::Concern

  # common ground for all representers

  included do
    include Roar::JSON
    include Roar::Hypermedia
    extend Format
    extend ThreeScale::Representer::Wrapping
    extend Wrapping
  end

  # This allows only JSON representers to merge XML content from the models
  def to_node(options)
    builder = ThreeScale::XML::Builder.new(skip_instruct: true)
    doc = options.fetch(:doc)
    xml = to_xml(builder: builder)

    Nokogiri::XML::Node.new('root', doc).add_child(xml)
  end

  module Format
    def format(_)
      self
    end
  end

  module Wrapping
    def wraps_collection(name)
      wraps_resource name

      self.instance_eval do
        include ThreeScale::CollectionRepresenter::JSONCollection
        include ThreeScale::CollectionRepresenter::XMLCollection
      end
    end
  end
end
