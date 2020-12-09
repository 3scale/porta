require 'test_helper'

class ThreeScale::Api::CollectionTest < ActiveSupport::TestCase
  include RepresentedApiRouting

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

  test '#to_json' do
    array_objects = %w[foo bar hello world].map { |word| Kla.new(word) }

    represented_without_any_pagination  = array_objects.dup
    represented_with_default_pagination = will_paginate_collection(total_entries: array_objects.size, collection: array_objects)
    represented_with_custom_pagination  = will_paginate_collection(page: 2, per_page: 1, total_entries: array_objects.size, collection: [array_objects[1]])

    collection_class_without_any_pagination  = KlasRepresenter.new(represented_without_any_pagination)
    collection_class_with_default_pagination = KlasRepresenter.new(represented_with_default_pagination)
    collection_class_with_custom_pagination  = KlasRepresenter.new(represented_with_custom_pagination)

    collection_module_without_any_pagination  = represented_without_any_pagination.extend(ModsRepresenter)
    collection_module_with_default_pagination = represented_with_default_pagination.extend(ModsRepresenter)
    collection_module_with_custom_pagination  = represented_with_custom_pagination.extend(ModsRepresenter)

    api_collection_with_class_without_any_pagination  = ThreeScale::Api::Collection.new(collection_class_without_any_pagination)
    api_collection_with_class_with_default_pagination = ThreeScale::Api::Collection.new(collection_class_with_default_pagination)
    api_collection_with_class_with_custom_pagination  = ThreeScale::Api::Collection.new(collection_class_with_custom_pagination)

    api_collection_with_module_without_any_pagination  = ThreeScale::Api::Collection.new(collection_module_without_any_pagination)
    api_collection_with_module_with_default_pagination = ThreeScale::Api::Collection.new(collection_module_with_default_pagination)
    api_collection_with_module_with_custom_pagination  = ThreeScale::Api::Collection.new(collection_module_with_custom_pagination)

    assert_equal '{"klass":[{"kla":{"foo":"foo"}},{"kla":{"foo":"bar"}},{"kla":{"foo":"hello"}},{"kla":{"foo":"world"}}]}',        api_collection_with_class_without_any_pagination.to_json
    assert_equal '{"klass":[{"kla":{"foo":"foo"}},{"kla":{"foo":"bar"}},{"kla":{"foo":"hello"}},{"kla":{"foo":"world"}}]}',        api_collection_with_class_with_default_pagination.to_json
    assert_equal '{"klass":[{"kla":{"foo":"bar"}}],"metadata":{"per_page":1,"total_entries":4,"total_pages":4,"current_page":2}}', api_collection_with_class_with_custom_pagination.to_json

    assert_equal '{"mods":[{"mod":{"foo":"foo"}},{"mod":{"foo":"bar"}},{"mod":{"foo":"hello"}},{"mod":{"foo":"world"}}]}',         api_collection_with_module_without_any_pagination.to_json
    assert_equal '{"mods":[{"mod":{"foo":"foo"}},{"mod":{"foo":"bar"}},{"mod":{"foo":"hello"}},{"mod":{"foo":"world"}}]}',         api_collection_with_module_with_default_pagination.to_json
    assert_equal '{"mods":[{"mod":{"foo":"bar"}}],"metadata":{"per_page":1,"total_entries":4,"total_pages":4,"current_page":2}}',  api_collection_with_module_with_custom_pagination.to_json
  end

  private

  def will_paginate_collection(page: 1, per_page: WillPaginate.per_page, total_entries:, collection:)
    WillPaginate::Collection.create(page, per_page, total_entries) { |pager| pager.replace(collection) }
  end
end
