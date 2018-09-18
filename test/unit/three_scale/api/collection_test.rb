require 'test_helper'

class ThreeScale::Api::CollectionTest < ActiveSupport::TestCase

  test '#to_xml' do
    collection = ThreeScale::Api::Collection.new([], root: :applications)
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><applications></applications>',
                  collection.to_xml
  end

  test 'ignores view attributes passed in the options hash' do
    garbage = { prefixes: [ 'stuff' ], layout: Proc.new {}, template: 'new' }
    collection = ThreeScale::Api::Collection.new([], garbage.merge(root: :apples))
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><apples></apples>',
                   collection.to_xml
  end

end
