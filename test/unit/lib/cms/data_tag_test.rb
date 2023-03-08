# frozen_string_literal: true

require 'test_helper'

class CMS::DataTagTest < ActiveSupport::TestCase

  class TaggedObject
    include CMS::DataTag

    has_data_tag :tagged_object
  end

  test 'data_tag is set' do
    assert_equal :tagged_object, TaggedObject.data_tag
  end
end
