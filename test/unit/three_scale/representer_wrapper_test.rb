# frozen_string_literal: true

require 'test_helper'

class ThreeScale::RepresenterWrapperTest < ActiveSupport::TestCase
  class Record
    attr_reader :id, :name

    def initialize(id:, name:)
      @id = id
      @name = name
    end

    def to_param
      "record-#{id}"
    end
  end

  class InlineRepresenter < ThreeScale::RepresenterWrapper
    wraps_representer(Module.new do
      include ThreeScale::JSONRepresenter

      wraps_resource

      property :id
      property :name
    end)
  end

  class InlineCollectionRepresenter < ThreeScale::CollectionRepresenter
    include ThreeScale::JSONRepresenter
    include Roar::JSON::Collection

    wraps_collection :records
    items extend: InlineRepresenter
  end

  test 'prepares an inline representer wrapper without extending the record' do
    record = Record.new(id: 42, name: 'Example')

    representer = InlineRepresenter.prepare(record)

    assert_instance_of InlineRepresenter, representer
    assert_same record, representer.record
    assert_equal 'record-42', representer.to_param
    assert_equal 'Example', representer.name
    assert_equal '{"record":{"id":42,"name":"Example"}}', representer.to_json
    assert_not_includes record.singleton_class.ancestors, InlineRepresenter
  end

  test 'uses the wrapper from collection items' do
    collection = InlineCollectionRepresenter.new(
      [
        Record.new(id: 1, name: 'First'),
        Record.new(id: 2, name: 'Second')
      ]
    )

    assert_equal '{"records":[{"record":{"id":1,"name":"First"}},{"record":{"id":2,"name":"Second"}}]}', collection.to_json
  end
end
