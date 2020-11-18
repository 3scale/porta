# frozen_string_literal: true

require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  class ProtectedApi < ApplicationRecord
    self.table_name = 'protected_apis'
    include Searchable
  end

  test 'by_query' do
    ProtectedApi.expects(:search).returns([1, 2, 3])
    ProtectedApi.expects(:where).with(id: [1, 2, 3]).returns(true)
    ProtectedApi.by_query('api')
  end

  test "by_query excludes sphinx_internal_class_name" do
    term = 'api'
    escaped_term = "@!sphinx_internal_class_name *#{term}*"
    sphinx_options = { ids_only: true, per_page: 1_000_000, star: false, ignore_scopes: true, with: {} }
    ProtectedApi.expects(:search).with(escaped_term, sphinx_options).returns([1, 2, 3])
    ProtectedApi.expects(:where).with(id: [1, 2, 3]).returns(true)
    ProtectedApi.by_query(term)
  end
end
