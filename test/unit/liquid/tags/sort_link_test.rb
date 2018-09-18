require 'test_helper'

class Liquid::Tags::SortLinkTest < ActiveSupport::TestCase

  test "syntax regexp" do
    {
      'column: "tracks"'                          => ['tracks'],
      'column: "tracks" label: "Songs"'           => ['tracks', 'Songs']
    }.each do | params, expected |
      match = params.match Liquid::Tags::SortLink::SYNTAX
      assert match
      assert_equal match[1], expected[0]
      assert_equal match[2], expected[1]
    end
  end

  # Using view context in the Tag .. so we need to setup a fake request
  test 'render' do
    controller = DeveloperPortal::Admin::Applications::AlertsController.new
    request = ActionDispatch::TestRequest.new
    request.parameters[:controller] = controller.controller_path
    request.parameters[:application_id] = '1'
    controller.stubs(request: request)
    _view = ActionView::Base.new('app/views', {}, controller)

    context = Liquid::Context.new
    context.registers[:controller] = controller
    tag = Liquid::Tags::SortLink.parse('th', '{% sort_link column: "foo" label: "Foo"  %}', [], {})

    rendered = tag.render(context)
    assert_match 'direction=asc', rendered
    assert_match 'sort=foo', rendered
  end

  # Using view context in the Tag .. so we need to setup a fake request
  test 'render when sortable is not defined' do
    controller = ApplicationController.new
    request = ActionDispatch::TestRequest.new
    request.parameters[:controller] = controller.controller_path
    controller.stubs(request: request)
    _view = ActionView::Base.new('app/views', {}, controller)

    context = Liquid::Context.new
    context.registers[:controller] = controller
    tag = Liquid::Tags::SortLink.parse('th', '{% sort_link column: "foo" label: "Foo"  %}', [], {})

    rendered = tag.render(context)
    assert_nil rendered
  end
end

