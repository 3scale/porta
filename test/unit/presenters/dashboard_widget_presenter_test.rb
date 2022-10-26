require 'test_helper'

class DashboardWidgetPresenterTest < Draper::TestCase
  def setup
    Draper::ViewContext.controller = Provider::Admin::Dashboard::WidgetController.new

    @service = FactoryBot.build_stubbed(:service)
    @widget = DashboardWidgetPresenter.new(:service_navigations, service_id: @service)
  end

  def test_value
    assert_equal @widget.spinner, @widget.value
  end

  def test_loaded?
    refute @widget.loaded?

    @widget.data = {}

    assert @widget.loaded?
  end

  def test_render
    assert @widget.render
  end

  def test_url
    assert_equal "http://test.host/p/admin/dashboard/service/#{@service.id}/navigations", @widget.url
  end

  def test_path
    assert_equal "/p/admin/dashboard/service/#{@service.id}/navigations", @widget.path
  end
end
