# frozen_string_literal: true

require 'test_helper'

class VerticalNavHelperTest < ActionView::TestCase

  test '#backend_api_nav_sections' do
    @backend_api = FactoryBot.create(:backend_api)

    # if permitted
    stubs(can?: true)
    assert_equal(backend_api_nav_sections.pluck(:title), ["Overview", "Analytics", "Methods & Metrics", "Mapping Rules"])

    # if not permitted
    stubs(can?: false)
    assert_equal(backend_api_nav_sections.pluck(:title), ["Overview", "Methods & Metrics", "Mapping Rules"])

    # When backend_api is not persisted
    @backend_api = BackendApi.new
    assert_equal(backend_api_nav_sections.pluck(:title), [])

  end
end
